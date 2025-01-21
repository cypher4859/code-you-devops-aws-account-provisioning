terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    backend "s3" {
      
    }
}

# Configure the AWS Provider
provider "aws" {
    # alias  = "management_account"
    region = "us-east-2"
    # profile = "blackhat-user"
}

provider "aws" {
    alias = "student_account"
    region = "us-east-2"

    assume_role {
      role_arn = module.new_cohort_aws_setup.new_account_ops_role_arn
    }

    #profile = "blackhat-user"
}

module "first-time-setup" {
    source = "./modules/first-time-setup"
    bucket_id = var.bucket_id
    github_repo = var.github_repo
    github_token = var.github_token
    environment = var.environment
    target_workflow = var.target_workflow
}

module "root_organization_setup" {
    source = "./modules/organization-setup"
    admins_json = var.admins_json
}

module "root_account_provisioning" {
  source = "./modules/root-iam-provisioning"
  admins_json = var.admins_json
}

# data "aws_secretsmanager_secret" "pgp_public_key" {
#   name = var.secretsmanager_secret_id_pgppublickey
# }

# data "aws_secretsmanager_secret_version" "pgp_public_key_version" {
#   secret_id = data.aws_secretsmanager_secret.pgp_public_key.id
# }

# TODO: Would be prudent to add some logic so we can build out multiple cohort accounts if
module "new_cohort_aws_setup" {
    source = "./modules/new-cohort-aws-setup"
    account_name = var.new_account_name
    account_owner_email = var.new_account_owner_email
    students_json = var.students_json
    management_admin_role_arn = module.root_account_provisioning.management_admin_role_arn
    management_billing_role_arn = module.root_account_provisioning.management_billing_role_arn
    management_org_id = module.root_organization_setup.management_org_id
    management_admin_group_arn = module.root_account_provisioning.management_admin_group_arn
    root_account_staff_admin_users = module.root_account_provisioning.management_admin_iam_users
    providers = {
      aws = aws.student_account
      aws.management_account = aws
      aws.student_account = aws.student_account
    }
}

module "post_account_provisioning" {
    source = "./modules/post-account-setup-provisioning"
    root_administrators_group_name = module.root_account_provisioning.management_administrators_group_name
    sub_account_id = module.new_cohort_aws_setup.new_account_id
    root_acct_staff_administrators_role_arn = module.root_account_provisioning.management_admin_role_arn
    sub_account_staff_administrators_role_arn = module.new_cohort_aws_setup.subaccount_staff_administrators_role_arn
    root_acct_staff_administrators_role_name = module.root_account_provisioning.managememnt_admin_role_name
}

module "upload_student_credentials" {
    source                  = "./modules/upload-student-credentials"
    bucket                  = var.bucket_id
    students_credentials    = module.new_cohort_aws_setup.student_passwords
    environment             = var.environment
}