locals {
    staff_administrators_group_name = "CodeYou_Staff_Administrators_Group"
    staff_billing_group_name        = "CodeYou_Staff_Billing_Group"
    mentor_group_name               = "CodeYou_Mentor_Group"
    student_group_name              = "CodeYou_Student_Group"
    students = { for student in data.external.students.result.students : student["Name"] => student }
}

# TODO: Need to add a job in the pipeline to auto-download the csv from S3
data "external" "students" {
    program = ["python3", "${path.module}/bin/parse_csv.py", "${path.module}/assets/students.csv"]
}

# TODO: Need to make more generic for mentors and other staff as well
# data "external" "mentors" {
#   program = ["python3", "${path.module}/bin/parse_csv.py", "${path.module}/assets/mentors.csv"]  
# }


resource "aws_iam_group" "student_group" {
    name = local.student_group_name
}

resource "aws_iam_group" "mentor_group" {
    name = local.mentor_group_name
}

resource "aws_iam_user" "student_user" {
    for_each = local.students
    name = each.value["name"]

    tags = {
        Email       = each.value["email"]
        Environment = "Student Cohort"
        RoleType    = "StudentUser"
    }
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

resource "aws_iam_user_group_membership" "student_user_membership" {
    for_each = local.students
    user = aws_iam_user.student_user[each.key].name
    groups = [
        aws_iam_group.student_group.name
    ]
}

# resource "aws_iam_user_group_membership" "mentor_user_membership" {
#     for_each = local.mentors
#     user = aws_iam_user.mentor_user[each.key].name
#     groups = [
#         aws_iam_group.mentor_group.name
#     ]
# }