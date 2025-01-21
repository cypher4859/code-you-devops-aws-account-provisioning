terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
            configuration_aliases = [ aws.management_account, aws.student_account ]
        }
    }
}

# FIXME: Roles and permissions needs fixed
module "management_roles_and_permissions" {
    source = "./sub_account_management_roles_and_permissions"
    management_admin_role_arn = var.management_admin_role_arn
    management_billing_role_arn = var.management_billing_role_arn
    management_org_id = var.management_org_id
    management_admin_group_arn = var.management_admin_group_arn
    root_account_staff_admin_users = [for iam_user in var.root_account_staff_admin_users : iam_user.arn] #var.root_account_staff_admin_users
    providers = {
      aws = aws
      aws.management_account = aws.management_account
    }
}

module "student_account_users_and_groups" {
    source = "./sub_account_users_and_groups"
    students_json = var.students_json
    providers = {
      aws = aws
      aws.management_account = aws.management_account
    }
}

module "subaccount_permissions_for_students" {
    source = "./sub_account_student_permissions_provisioning"
    student_role_name = "DevOps-CodeYou-Student-Role"
    student_group_name = module.student_account_users_and_groups.student_group_name
    providers = {
      aws = aws
      aws.management_account = aws.management_account
    }
}