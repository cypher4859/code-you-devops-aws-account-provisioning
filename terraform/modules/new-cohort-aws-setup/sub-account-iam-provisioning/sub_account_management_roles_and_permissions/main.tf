terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.management_account]
    }
  }
}

# Default AWS provider is the `student_account`

data "aws_caller_identity" "current" {}


locals {
  staff_billing_role_name        = var.staff_billing_role_name
  staff_administrators_role_name = var.staff_administrators_role_name
  mentor_role_name               = var.mentor_role_name
  student_role_name              = var.student_role_name
  account_id                     = data.aws_caller_identity.current.account_id
}

# TODO: Setup some common tags at the module level so it's easy to 
# access and reuse common tag keys and values.
resource "aws_iam_role" "staff_administrators_role" {
  name               = local.staff_administrators_role_name
  assume_role_policy = data.aws_iam_policy_document.staff_administrators_trust_policy.json

  tags = {
    Environment = "Student Cohort"
    RoleType    = "StaffAdministrator"
  }
}

resource "aws_iam_role_policy_attachment" "staff_administrators_policy_attachment" {
  role       = aws_iam_role.staff_administrators_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" 
}

resource "aws_iam_role" "staff_billing_role" {
  name               = local.staff_billing_role_name
  assume_role_policy = data.aws_iam_policy_document.staff_billing_trust_policy.json

  tags = {
    Environment = "Student Cohort"
    RoleType    = "StaffBilling"
  }
}

resource "aws_iam_role_policy" "staff_billing_role_policy" {
  name   = "CodeYou_Staff_Billing_Policy"
  role   = aws_iam_role.staff_billing_role.id
  policy = data.aws_iam_policy_document.staff_billing_permissions_policy_document.json
}

# TODO: The mentor role needs correct permissions
resource "aws_iam_role" "mentor_role" {
  name               = local.mentor_role_name
  assume_role_policy = data.aws_iam_policy_document.mentor_trust_policy.json

  tags = {
    Environment = "Student Cohort"
    RoleType    = "Mentor"
  }   
}

resource "aws_iam_role_policy" "mentor_role_permissions_policy" {
  name   = "CodeYou_Staff_Mentor_Policy"
  role   = aws_iam_role.mentor_role.id
  policy = data.aws_iam_policy_document.mentor_permission_policy.json
}

