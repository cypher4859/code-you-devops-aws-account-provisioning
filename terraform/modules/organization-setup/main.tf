terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

# FIXME: TURN ON for new root account provisioning, i.e. on a brand new account that will host the Org
# resource "aws_organizations_organization" "root_org" {
#   feature_set = "ALL"
# }

data "aws_organizations_organization" "root_org" {}

data "aws_iam_policy_document" "free_tier_only_scp" {
  # Allow managing ECS services and Task Definitions
  statement {
    sid       = "AllowECSManagement"
    actions   = [
      "ecs:*", # Full ECS access for services and task definitions
      "iam:*" # Required to associate roles with ECS tasks
    ]
    resources = ["*"]
  }

  statement {
    sid         = "AllowKMS"
    actions     = [
      "kms:*"
    ]
    resources = ["*"]
  }

  statement {
    sid         = "AllowDynamoDB"
    actions     = [
      "dynamodb:*"
    ]
    resources = ["*"]
  }

  statement {
    sid         = "AllowRDS"
    actions     = [
      "rds:*"
    ]
    resources = ["*"]
  }

  # Allow creating and managing Autoscaling groups
  statement {
    sid       = "AllowAutoScaling"
    actions   = [
      "autoscaling:*"
    ]
    resources = ["*"]
  }

  # Allow managing S3 buckets
  statement {
    sid       = "AllowS3FreeTier"
    actions   = [
      "s3:*"
    ]
    resources = ["*"]
  }

  # Allow managing CloudWatch metrics and alarms
  statement {
    sid       = "AllowCloudWatchFreeTier"
    actions   = [
      "cloudwatch:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowCloudFormation"
    actions   = [
      "cloudformation:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowCloudTrail"
    actions   = [
      "cloudtrail:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowTagging"
    actions   = [
      "ec2:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowLoadBalancing"
    actions   = [
      "elasticloadbalancing:*"
    ]
    resources = ["*"]
  }

  statement {
    sid         = "AllowEFS"
    actions     = [
      "elasticfilesystem:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowLogs"
    actions   = [
      "logs:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowSSM"
    actions   = [
      "ssm:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowECR"
    actions   = [
      "ecr:*"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowLambda"
    actions = [
      "lambda:*"
    ]
    resources = ["*"]
  }
}



resource "aws_organizations_policy" "root_scp" {
  name        = "DenyCertainServices"
  description = "Deny access to certain services for member accounts"
  content     = data.aws_iam_policy_document.free_tier_only_scp.json
  type = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "root_attachment" {
  policy_id = aws_organizations_policy.root_scp.id
  target_id = data.aws_organizations_organization.root_org.roots[0].id
}