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

locals {
  root_account_id = data.aws_caller_identity.root.account_id
}

resource "aws_iam_role" "cloudwatch_observability_role" {
  name = "CloudWatchObservabilityRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${local.root_account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_observability_policy" {
  name = "CloudWatchObservabilityPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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

resource "aws_iam_role_policy_attachment" "attach_observability_policy" {
  role       = aws_iam_role.cloudwatch_observability_role.name
  policy_arn = aws_iam_policy.cloudwatch_observability_policy.arn
}
