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
module "roles_and_permissions" {
    source = "./sub_account_roles_and_permissions"
    management_admin_role_arn = var.management_admin_role_arn
    management_billing_role_arn = var.management_billing_role_arn
    management_org_id = var.management_org_id
    management_admin_group_arn = var.management_admin_group_arn
    providers = {
      aws = aws
      aws.management_account = aws.management_account
    }
}

module "users_and_groups" {
    source = "./sub_account_users_and_groups"
    students_json = var.students_json
}