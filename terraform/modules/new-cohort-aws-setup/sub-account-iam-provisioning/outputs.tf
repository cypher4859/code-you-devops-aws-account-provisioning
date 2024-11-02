output "students" {
    description = "List of student IAM users"
    value = module.users_and_groups.students
}

output "staff_administrators_role_arn" {
  value = module.roles_and_permissions.staff_administrators_role_arn
}