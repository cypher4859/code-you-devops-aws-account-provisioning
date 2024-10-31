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
    alias  = "management_account"
    region = "us-east-2"
}

provider "aws" {
    alias = "student_account"
    region = "us-east-2"

    assume_role {
      role_arn = module.new_cohort_aws_setup.new_account_ops_role_arn
    }
}

module "root_organization_setup" {
    source = "./modules/organization-setup"
}

# TODO: Would be prudent to add some logic so we can build out multiple cohort accounts if
module "new_cohort_aws_setup" {
    source = "./modules/new-cohort-aws-setup"
    account_name = ""
    account_owner_email = ""
}

# Create network infrastructure
# module "_network_infra" {
#     source = "./modules/network-infra"
#     vpc_id = "vpc-3771c65c" # Grabbed from the console
#     public_subnet_id = "subnet-03595f11b44edacc8"
# }
