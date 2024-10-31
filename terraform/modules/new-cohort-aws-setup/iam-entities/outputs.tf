output "students" {
    description = "List of student IAM users"
    value = module.users_and_groups.students
}