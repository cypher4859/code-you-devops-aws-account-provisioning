output "students" {
  description = "List of student IAM users"
  value = local.student_names
}

output "student_iam_users" {
  description = "The IAM users we created for students"
  value = aws_iam_user.student_user
}

output "student_group_arn" {
  description = "The IAM Group ARN that will hold students"
  value = aws_iam_group.student_group.arn
}

output "student_group_name" {
  description = "The IAM Group name that will hold students"
  value = aws_iam_group.student_group.name
}

output "student_passwords" {
  value = {
    for key, user in aws_iam_user.student_user : local.students[key].name => { 
      email             = local.students[key].email
      name              = local.students[key].name
      password          = aws_iam_user_login_profile.student_user_login[key].password
      access_key_id     = aws_iam_access_key.student_user_access_keys[key].id
      secret_access_key  = aws_iam_access_key.student_user_access_keys[key].secret
    }
  }
  sensitive = true
}
