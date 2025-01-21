output "new_account_ops_role_arn" {
  value = module.new_aws_account.org_account_ops_role_arn
}

output "new_account_id" {
  value = module.new_aws_account.new_account_id
}

output "staff_administrators_role_arn" {
  value = module.iam-entities.staff_administrators_role_arn
}

output "subaccount_staff_administrators_role_arn" {
  value = module.iam-entities.staff_administrators_role_arn
}

output "student_passwords" {
  value = module.iam-entities.student_passwords
  sensitive = true
}