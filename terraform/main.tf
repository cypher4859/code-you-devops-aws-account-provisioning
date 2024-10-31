terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    backend "s3" {
        bucket = "blackcypher-ops-bucket"
        key    = "terraform/state/code-you/devops-with-aws/admin-provisioning/terraform.tfstate"
        region = "us-east-2"
        encrypt = true
    }
}

# Configure the AWS Provider
provider "aws" {
    # alias  = "management_account"
    region = "us-east-2"
    profile = "blackhat-user"
}

provider "aws" {
    alias = "student_account"
    region = "us-east-2"

    assume_role {
      role_arn = module.new_cohort_aws_setup.new_account_ops_role_arn
    }

    profile = "blackhat-user"
}

module "root_organization_setup" {
    source = "./modules/organization-setup"
}

# TODO: Would be prudent to add some logic so we can build out multiple cohort accounts if
module "new_cohort_aws_setup" {
    source = "./modules/new-cohort-aws-setup"
    account_name = var.new_account_name
    account_owner_email = var.new_account_owner_email
    students_json = var.students_json
    providers = {
      aws = aws.student_account
      aws.management_account = aws
    }
}
