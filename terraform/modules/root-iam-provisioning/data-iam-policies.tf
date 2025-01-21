data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

}

data "aws_iam_policy_document" "staff_administrators_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [
        "*"
      ]
    }

    # Optionally, add conditions to restrict further, e.g., based on tags or user names
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Group"
      values   = [
        aws_iam_group.administrators_group.name,
      ]
    }
  }
}

data "aws_iam_policy_document" "staff_billing_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [
        "*"
      ]
    }

    # Optionally, add conditions to restrict further, e.g., based on tags or user names
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Group"
      values   = [
        aws_iam_group.administrators_group.name,
        aws_iam_group.billing_group.name
      ]
    }
  }
}

# data "aws_iam_policy_document" "admin_group_trust_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "sts:AssumeRole",
#     ]

#     principals {
#       type        = "AWS"
#       identifiers = [
#         "arn:aws:iam::${local.account_id}:root"
#       ]
#     }
#   }
# }
