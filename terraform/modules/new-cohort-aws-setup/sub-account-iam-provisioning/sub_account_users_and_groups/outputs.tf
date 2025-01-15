output "students" {
    description = "List of student IAM users"
    value = local.student_names
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