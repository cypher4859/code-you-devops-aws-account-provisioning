terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    #   configuration_aliases = [ aws.student_account ]
    }
  }
}

locals {
    staff_administrators_group_name = "CodeYou_Staff_Administrators_Group"
    staff_billing_group_name        = "CodeYou_Staff_Billing_Group"
    mentor_group_name               = "CodeYou_Mentor_Group"
    student_group_name              = "CodeYou_Student_Group"
    # Reconstructing the student map from flattened data
    students = {
        for student in jsondecode(var.students_json) : student.name => student
    }

    student_names = [for student in local.students : student.name]
}

# TODO: Need to add a job in the pipeline to auto-download the csv from S3
# TODO: Need to make more generic for mentors and other staff as well


resource "aws_iam_group" "student_group" {
    name = local.student_group_name

    
}

resource "aws_iam_group" "mentor_group" {
    name = local.mentor_group_name

    
}

resource "aws_iam_user" "student_user" {
    for_each = local.students
    name  = each.value.name

    tags = {
        Email       = each.value.email
        Environment = "Student Cohort"
        RoleType    = "StudentUser"
    }
}

resource "aws_iam_user_login_profile" "student_user_login" {
  for_each = local.students
  user                      = aws_iam_user.student_user[each.key].name  # Reference to the IAM user you've created
  password_reset_required   = true       # Optionally force the user to reset the password on first login
  password_length           = 16
#   pgp_key                   = "keybase:username"         # PGP key to secure the password output (optional)
}


resource "aws_iam_user_group_membership" "student_user_membership" {
    for_each = local.students
    user = aws_iam_user.student_user[each.key].name
    groups = [
        aws_iam_group.student_group.name
    ]    
}

# resource "aws_iam_user" "mentor_user" {
#     for_each = local.mentors
#     name = each.value["name"]

#     tags = {
#         Email       = each.value["email"]
#         Environment = "Student Cohort"
#         RoleType    = "MentorUser"
#     }


# }

# resource "aws_iam_user_group_membership" "mentor_user_membership" {
#     for_each = local.mentors
#     user = aws_iam_user.mentor_user[each.key].name
#     groups = [
#         aws_iam_group.mentor_group.name
#     ]


# }
