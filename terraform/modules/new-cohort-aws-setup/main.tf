
locals {
  org_account_ops_role_name = "OrganizationAccountAccessRole"
}
# Grab file of students from S3

# Create a new AWS account
module "new_aws_account" {
  source = "./aws-account"
  new_account_name = var.account_name
  new_account_email_address = var.account_owner_email
  new_account_org_role_name = local.org_account_ops_role_name
}

module "iam-entities" {
  source = "./iam-entities"
  new_account_id = module.new_aws_account.new_account_id
  providers = {
    aws = aws.student_account
  }
}

module "github-role-authentication" {
  source = "../github-role-setup"
  new_account_id = module.new_aws_account.new_account_id
  providers = {
    aws = aws.student_account
  }
}

# TODO: Every student should get their own subnet with at least 2 availability zones
module "network-infrastructure" {
  source = "."
}

# Ensure it's related to the Organization

# Create the SCPs for the new account


# Create the IAM role for the Github pipeline