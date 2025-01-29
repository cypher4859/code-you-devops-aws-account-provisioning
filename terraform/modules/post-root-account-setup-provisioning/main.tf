data "aws_region" "current" {

}

data "aws_caller_identity" "current" {
  
}

locals {
  root_administrators_group_name = var.root_administrators_group_name
  account_id = data.aws_caller_identity.current.account_id
  sub_account_id = var.sub_account_id
  staff_administrators_role_arn = var.root_acct_staff_administrators_role_arn
  sub_account_staff_administrators_role_arn = var.sub_account_staff_administrators_role_arn
  root_staff_administrators_role_name = var.root_acct_staff_administrators_role_name
  sub_account_observability_role_arn = var.sub_account_observability_role_arn
  dynamic_dashboard_updater_lambda_name = var.dynamic_dashboard_updater_lambda_name
  region = data.aws_region.current.name
}

data "aws_iam_policy_document" "admin_group_permissions_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      local.sub_account_staff_administrators_role_arn,
      local.staff_administrators_role_arn
    ]
  }
}

data "aws_iam_policy_document" "cross_account_assume_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      local.sub_account_staff_administrators_role_arn
    ]
  }
}

resource "aws_iam_policy" "admin_group_permissions_policy" {
  name        = "CodeYou_Root_AdminGroup_PermissionsPolicy"
  description = "IAM Policy for administrators group to assume roles in sub account"
  policy      = data.aws_iam_policy_document.admin_group_permissions_policy.json
}

resource "aws_iam_group_policy_attachment" "administrators_policy_attachment" {
  group      = local.root_administrators_group_name
  policy_arn = aws_iam_policy.admin_group_permissions_policy.arn
}

resource "aws_iam_role_policy" "cross_account_assume_policy" {
  name      = "CrossAccountAssumePolicy"
  role      = local.root_staff_administrators_role_name
  policy    = data.aws_iam_policy_document.cross_account_assume_policy.json
}

data "archive_file" "dynamic_dashboard_updater_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/dynamic-dashboard-code" # Replace with your directory path
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_iam_role" "lambda_ec2_monitor_role" {
  name = "lambda-ec2-monitor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_permissions" {
  name = "LambdaCrossAccountMonitorPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:AssumeRole"
        ],
        Resource = local.sub_account_observability_role_arn
      },
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutDashboard",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_ec2_monitor_role.name
  policy_arn = aws_iam_policy.lambda_permissions.arn
}

resource "aws_lambda_function" "dynamic_dashboard_updater" {
  function_name = local.dynamic_dashboard_updater_lambda_name
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_ec2_monitor_role.arn
  handler       = "main.lambda_handler"
  timeout       = 30
  filename      = data.archive_file.dynamic_dashboard_updater_lambda_zip.output_path

  environment {
    variables = {
      SUB_ACCOUNT_ROLE_ARN = local.sub_account_observability_role_arn # Sub-Account Role ARN
      ROOT_CLOUDWATCH_TARGET_REGION = local.region
    }
  }
}


resource "aws_iam_role" "eventbridge_cross_account_role" {
  name     = "EventBridgeCrossAccountRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root" # Replace with Root Account ID
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Policy to Allow EventBridge to Send Events to Root Account EventBus
resource "aws_iam_role_policy" "eventbridge_policy" {
  role     = aws_iam_role.eventbridge_cross_account_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "events:PutEvents"
        ],
        Resource = "arn:aws:events:${local.region}:${local.account_id}:event-bus/default" # Replace with Root Account EventBus ARN
      }
    ]
  })
}


resource "aws_cloudwatch_event_rule" "ec2_state_change_rule" {
  name        = "EC2StateChangeRule"
  description = "Triggers Lambda on EC2 state changes"
  event_pattern = jsonencode({
    source = ["aws.ec2"],
    detail = {
      state = ["running", "stopped", "terminated", "pending"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change_rule.name
  target_id = "DynamicDashboardUpdaterRootLambda"
  arn       = aws_lambda_function.dynamic_dashboard_updater.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamic_dashboard_updater.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change_rule.arn
}

# Allow Sub-Account to Put Events into the Root Account EventBus
resource "aws_cloudwatch_event_permission" "OrganizationAccess" {
  principal    = local.account_id
  statement_id = "RootAccountAccess"
}


