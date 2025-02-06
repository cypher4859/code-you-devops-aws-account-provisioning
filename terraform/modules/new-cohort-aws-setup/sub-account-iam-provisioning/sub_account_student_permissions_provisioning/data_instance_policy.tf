data "aws_iam_policy_document" "ecs_instance_policy" {
  statement {
    sid    = "AllowECSIntegration"
    effect = "Allow"
    actions = [
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:UpdateContainerInstancesState",
        "ecs:Submit*",
        "ecs:TagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid   = "AllowUntaggingOnOwnersStuff"
    effect = "Allow"
    actions = [
      "ecs:UntagResource"
    ]
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "ecs:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "AllowCloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowECRAccess"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EcsReadOnly"
    effect = "Allow"
    actions = [
      "ecs:List*",
      "ecs:Describe*",
      "servicediscovery:List*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "challenge_lambda_function_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "challenge_lambda_function_permissions_policy" {
  statement {
    sid    = "AllowChallengeLambdaFunctionToS3Things"
    effect = "Allow"
    actions = [
        "s3:GetObject",
        "s3:PutObject",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}
