output "student_passwords" {
  value = module.new_cohort_aws_setup.student_passwords
  sensitive = true
}

output "new_account_ops_role_arn" {
  value = module.new_cohort_aws_setup.new_account_ops_role_arn
}

output "new_account_id" {
  value = module.new_cohort_aws_setup.new_account_id
}

output "staff_administrators_role_arn" {
  value = module.new_cohort_aws_setup.staff_administrators_role_arn
}

output "root_admin_users" {
  value = module.root_account_provisioning.management_admin_iam_users
  sensitive = true
}

# output "debug_pgp_key" {
#   value     = data.aws_secretsmanager_secret_version.pgp_public_key_version.secret_string
#   sensitive = true
# }