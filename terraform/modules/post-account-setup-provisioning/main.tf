locals {
  root_administrators_group_name = var.root_administrators_group_name
  sub_account_id = var.sub_account_id
  staff_administrators_role_arn = var.root_acct_staff_administrators_role_arn
  sub_account_staff_administrators_role_arn = var.sub_account_staff_administrators_role_arn
  root_staff_administrators_role_name = var.root_acct_staff_administrators_role_name
}

data "aws_iam_policy_document" "admin_group_permissions_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
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