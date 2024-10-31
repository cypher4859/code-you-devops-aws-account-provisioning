# TODO: Ensure that the roles from the management account can access the sub-accounts

data "aws_iam_policy_document" "staff_billing_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["billing.amazonaws.com"] # Update as appropriate
    }
  }
}

data "aws_iam_policy_document" "staff_billing_policy_document" {
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

data "aws_iam_policy_document" "mentor_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] # Update as appropriate
    }
  }
}

data "aws_iam_policy_document" "student_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] # Update as appropriate
    }
  }
}

data "aws_iam_policy_document" "student_policy_document" {
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