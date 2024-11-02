# TODO: Ensure that the roles from the management account can access the sub-accounts

locals {
  management_admin_role_arn = var.management_admin_role_arn
  management_admin_group_arn = var.management_admin_group_arn
  management_billing_role_arn = var.management_billing_role_arn
}

data "aws_iam_policy_document" "staff_billing_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [
        local.management_admin_role_arn,
        local.management_billing_role_arn
      ]
    }
  }
}

data "aws_iam_policy_document" "staff_billing_permissions_policy_document" {
  statement {
    actions = [
      "tag:GetResources",
      "tag:TagResources",
      "tag:UntagResources",
      "tag:GetTagKeys",
      "tag:GetTagValues"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ce:GetCostAndUsage",
      "ce:GetCostForecast",
      "ce:GetSavingsPlansUtilization",
      "ce:GetReservationUtilization",
      "ce:GetDimensionValues",
      "ce:GetCostCategories",
      "ce:GetSavingsPlansCoverage",
      "ce:GetRightsizingRecommendation"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "aws-portal:ViewBilling",
      "aws-portal:ViewUsage",
      "aws-portal:ViewPaymentMethods",
      "aws-portal:ViewAccount"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "organizations:DescribeOrganization",
      "organizations:ListAccounts",
      "organizations:DescribeAccount",
      "organizations:ListPolicies",
      "organizations:DescribePolicy"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "staff_administrators_trust_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Group"
      values   = [local.management_admin_group_arn]
    }
  }
}

data "aws_iam_policy_document" "mentor_trust_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        local.management_admin_role_arn
      ]
    }
  }
}

data "aws_iam_policy_document" "mentor_permission_policy" {
  statement {
    sid    = "ECSPermissions"
    effect = "Allow"
    actions = [
      "ecs:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "student_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] # Update as appropriate
    }
  }
}

data "aws_iam_policy_document" "student_permission_policy" {
  statement {
    sid    = "ECSPermissions"
    effect = "Allow"
    actions = [
      "ecs:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "SQSPermissions"
    effect = "Allow"
    actions = [
      "sqs:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "EBSPermissions"
    effect = "Allow"
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "SNSPermissions"
    effect = "Allow"
    actions = [
      "sns:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "S3Permissions"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid      = "ApplicationAutoScalingPermissions"
    effect   = "Allow"
    actions  = [
      "application-autoscaling:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:userid}"]
    }
  }

  statement {
    sid      = "ElasticLoadBalancingPermissions"
    effect   = "Allow"
    actions  = [
      "elasticloadbalancing:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:userid}"]
    }
  }

  statement {
    sid      = "AutoScalingPermissions"
    effect   = "Allow"
    actions  = [
      "autoscaling:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:userid}"]
    }
  }
}
