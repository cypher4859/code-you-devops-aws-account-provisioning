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

    # profile = "blackhat-user"
}

module "first-time-setup" {
    source = "./modules/first-time-setup"
    bucket_id = var.bucket_id
    github_repo = var.github_repo
    github_token = var.github_token
    environment = var.environment
    target_workflow = ""
}

module "root_organization_setup" {
    source = "./modules/organization-setup"
    admins_json = var.admins_json
}

module "root_account_provisioning" {
  source = "./modules/root-iam-provisioning"
  admins_json = var.admins_json
}

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
    student_acct_staff_administrators_role_arn = module.new_cohort_aws_setup.staff_administrators_role_arn
}
