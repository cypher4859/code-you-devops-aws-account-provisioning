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

output "bucket_path_to_credentials_file" {
  description = "The key path in the bucket to get the credential file"
  value = module.upload_student_credentials.bucket_path_to_credentials_file
  sensitive = true
}

output "bucket_for_credentials" {
  description = "The bucket that holds the credential file"
  value = module.upload_student_credentials.bucket_for_credentials
  sensitive = true
}

# output "debug_pgp_key" {
#   value     = data.aws_secretsmanager_secret_version.pgp_public_key_version.secret_string
#   sensitive = true
# }