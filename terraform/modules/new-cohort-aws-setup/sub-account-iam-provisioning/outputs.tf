output "students" {
    description = "List of student IAM users"
    value = module.student_account_users_and_groups.students
}

output "staff_administrators_role_arn" {
  value = module.management_roles_and_permissions.staff_administrators_role_arn
}

output "student_passwords" {
  value = module.student_account_users_and_groups.student_passwords
  sensitive = true
}

output "observability_role_arn" {
  value = module.subaccount_permissions_for_monitoring.subaccount_observability_role_arn
}
