terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

module "roles_and_permissions" {
    source = "./sub_account_roles_and_permissions"
    management_aws_account_id = var.management_account_id
}

module "users_and_groups" {
    source = "./sub_account_users_and_groups"
    students_json = var.students_json
}