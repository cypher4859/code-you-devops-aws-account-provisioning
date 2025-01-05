terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

# FIXME: This needs turned back on for a fresh account
# resource "aws_organizations_organization" "root_org" {
#   feature_set = "ALL"
# }

data "aws_organizations_organization" "root_org" {}

# TODO: Need to fill out the SCP
# - Enforce tagging of `Owner`

data "aws_iam_policy_document" "free_tier_only_scp" {
  # Allow managing EC2 instances within free-tier limits
  statement {
    sid       = "AllowEC2FreeTier"
    actions   = [
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:Describe*",
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:ModifyInstanceAttribute"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:InstanceType"
      values   = ["t2.micro", "t3.micro"] # Free-tier instance types
    }
  }

  # Allow managing ECS services and Task Definitions
  statement {
    sid       = "AllowECSManagement"
    actions   = [
      "ecs:*", # Full ECS access for services and task definitions
      "iam:PassRole" # Required to associate roles with ECS tasks
    ]
    resources = ["*"]
  }

  # Allow creating and managing Autoscaling groups
  statement {
    sid       = "AllowAutoScaling"
    actions   = [
      "autoscaling:*",
      "ec2:DescribeLaunchTemplates",
      "ec2:CreateLaunchTemplate",
      "ec2:DeleteLaunchTemplate"
    ]
    resources = ["*"]
  }

  # Allow managing S3 buckets
  statement {
    sid       = "AllowS3FreeTier"
    actions   = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = ["*"]
  }

  # Allow managing CloudWatch metrics and alarms
  statement {
    sid       = "AllowCloudWatchFreeTier"
    actions   = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms"
    ]
    resources = ["*"]
  }

  # Deny any operations outside the free-tier scope
  statement {
    sid       = "DenyNonFreeTierOperations"
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "aws:RequestTag/AllowFreeTierOnly"
      values   = ["false"]
    }
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