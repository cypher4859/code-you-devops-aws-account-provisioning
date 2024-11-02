terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
            configuration_aliases = [aws.student_account, aws.management_account]
        }
    }
}

data "aws_caller_identity" "management_current" {
  provider = aws.management_account
}

data "aws_caller_identity" "student_current" {}

locals {
  org_account_ops_role_name = "OrganizationAccountAccessRole"
  management_account_id = data.aws_caller_identity.management_current.account_id
}
# Grab file of students from S3

# Create a new AWS account
module "new_aws_account" {
  source = "./aws-account"
  new_account_name = var.account_name
  new_account_email_address = var.account_owner_email
  new_account_org_role_name = local.org_account_ops_role_name
  providers = {
    aws = aws.management_account
  }
}


module "iam-entities" {
  source = "./sub-account-iam-provisioning"
  students_json = var.students_json
  management_admin_role_arn = var.management_admin_role_arn
  management_billing_role_arn = var.management_billing_role_arn
  management_org_id = var.management_org_id
  management_admin_group_arn = var.management_admin_group_arn
  depends_on = [ module.new_aws_account ]
  providers = {
    aws = aws.student_account
    aws.management_account = aws.management_account
    aws.student_account = aws.student_account
  }
}

module "student-network-infrastructure" {
  source = "./student-network-infra"
  students = module.iam-entities.students
  depends_on = [ module.iam-entities ]
}

# module "github-role-authentication" {
#   source = "../github-role-setup"
#   new_account_id = module.new_aws_account.new_account_id
#   depends_on = [ module.new_aws_account, module.iam-entities ]
# }