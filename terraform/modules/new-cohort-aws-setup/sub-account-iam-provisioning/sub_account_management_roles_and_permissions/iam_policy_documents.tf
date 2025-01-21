# TODO: Ensure that the roles from the management account can access the sub-accounts

locals {
  management_admin_role_arn = var.management_admin_role_arn
  management_admin_group_arn = var.management_admin_group_arn
  management_billing_role_arn = var.management_billing_role_arn
  root_account_staff_admin_users = var.root_account_staff_admin_users
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
      identifiers = concat(
        [local.management_admin_role_arn],
        local.root_account_staff_admin_users
        # [for iam_user in local.root_account_staff_admin_users : iam_user.arn]
      )
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


