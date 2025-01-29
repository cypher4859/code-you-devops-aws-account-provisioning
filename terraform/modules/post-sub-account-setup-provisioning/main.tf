terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.management_account]
    }
  }
}

data "aws_caller_identity" "root" {
  provider = aws.management_account
}

data "aws_caller_identity" "subaccount" {
  
}

locals {
  dynamic_dashboard_updater_arn = var.dynamic_dashboard_updater_lambda_arn
  dynamic_dashboard_updater_name = var.dynamic_dashboard_updater_lambda_name
  root_account_id = data.aws_caller_identity.root.account_id
  subaccount_id = data.aws_caller_identity.subaccount.account_id
  lambda_function_region = var.lambda_function_region
}

resource "aws_iam_role" "eventbridge_cross_account_role" {
  name     = "EventBridgeCrossAccountRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${local.root_account_id}:root" # Replace with Root Account ID
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
        Resource = "arn:aws:events:${local.lambda_function_region}:${local.root_account_id}:event-bus/default" # Replace with Root Account EventBus ARN
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
      state = ["running", "stopped", "terminated"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change_rule.name
  target_id = "DynamicDashboardUpdaterRootLambda"
  arn       = local.dynamic_dashboard_updater_arn
  role_arn = aws_iam_role.eventbridge_cross_account_role.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = local.dynamic_dashboard_updater_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change_rule.arn
}

# Allow Sub-Account to Put Events into the Root Account EventBus
resource "aws_cloudwatch_event_permission" "OrganizationAccess" {
  principal    = local.root_account_id
  statement_id = "RootAccountAccess"
}

