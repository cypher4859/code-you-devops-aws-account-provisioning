output "students" {
    description = "List of student IAM users"
    value = local.student_names
}

output "student_passwords" {
  value = {
    for key, user in aws_iam_user.student_user : user.name => aws_iam_user_login_profile.student_user_login[key].encrypted_password
  }
  sensitive = true
}