terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # configuration_aliases = [ aws.student_account ]
    }
  }
}

locals {
  staff_billing_role_name        = var.staff_billing_role_name
  staff_administrators_role_name = var.staff_administrators_role_name
  mentor_role_name               = var.mentor_role_name
  student_role_name              = var.student_role_name
}

# resource "aws_iam_role" "staff_administrators_role" {
#   name               = local.staff_administrators_role_name
#   assume_role_policy = data.aws_iam_policy_document.staff_administrators_policy.json

#   tags = {
#     Environment = "Student Cohort"
#     RoleType    = "StaffAdministrator"
#   }
# }

# resource "aws_iam_role_policy_attachment" "staff_administrators_policy_attachment" {
#   role       = aws_iam_role.staff_administrators_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"   
# }

# resource "aws_iam_role" "staff_billing_role" {
#   name               = local.staff_billing_role_name
#   assume_role_policy = data.aws_iam_policy_document.staff_billing_policy.json

#   tags = {
#     Environment = "Student Cohort"
#     RoleType    = "StaffBilling"
#   }
# }

# resource "aws_iam_role_policy" "staff_billing_role_policy" {
#   name   = "CodeYou_Staff_Billing_Policy"
#   role   = aws_iam_role.staff_billing_role.id
#   policy = data.aws_iam_policy_document.staff_billing_policy_document.json

   
# }

# TODO: The mentor role needs correct permissions
resource "aws_iam_role" "mentor_role" {
  name               = local.mentor_role_name
  assume_role_policy = data.aws_iam_policy_document.mentor_policy.json

  tags = {
    Environment = "Student Cohort"
    RoleType    = "Mentor"
  }

   
}

resource "aws_iam_role" "student_role" {
  name               = local.student_role_name
  assume_role_policy = data.aws_iam_policy_document.student_policy.json

  tags = {
    Environment = "Student Cohort"
    RoleType    = "Student"
  }

   
}


