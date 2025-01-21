locals {
  staff_administrators_group_policy_name = "CodeYou-Mamangement-AdministratorsGroup"
  crossaccount_staff_administrators_role_name = "CrossAccount-CodeYou-Staff-Administrators-Role"
  staff_billing_role_name = "CrossAccount-CodeYou-Staff-Billing-Role"
  staff_administrators_group_name = "CodeYouAdministratorsGroup"
  staff_billing_group_name = "CodeYouBillingUsersGroup"
  administrators = {
        for admin in jsondecode(var.admins_json) : admin.name => admin
    }
}

resource "aws_iam_role" "cross_account_staff_administrators_role" {
  name               = local.crossaccount_staff_administrators_role_name
  assume_role_policy = data.aws_iam_policy_document.staff_administrators_trust_policy.json

  tags = {
    Environment = "Management"
    RoleType    = "StaffAdministrator"
  }
}

// TODO: Does cross account staff admin role need admin access?
resource "aws_iam_group_policy_attachment" "staff_administrators_group_permissions_attachement" {
  group      = aws_iam_group.administrators_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" 
}

resource "aws_iam_group" "administrators_group" {
  name = local.staff_administrators_group_name
}

resource "aws_iam_group" "billing_group" {
  name = local.staff_billing_group_name
}

resource "aws_iam_user" "admin_user" {
    for_each = local.administrators
    name  = each.value.name

    tags = {
        Email       = each.value.email
        Environment = "Management"
        RoleType    = "AdministratorUser"
        Group       = aws_iam_group.administrators_group.name
    }
}

resource "aws_iam_user_group_membership" "administrators_user_membership" {
    for_each = local.administrators
    user = aws_iam_user.admin_user[each.key].name
    groups = [
        aws_iam_group.administrators_group.name
    ]    
}

resource "aws_iam_role" "staff_billing_role" {
  name               = local.staff_billing_role_name
  assume_role_policy = data.aws_iam_policy_document.staff_billing_trust_policy.json

  tags = {
    Environment = "Management"
    RoleType    = "StaffBilling"
  }
}
