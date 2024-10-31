output "new_account_id" {
  description = "Account ID of the newly created AWS account"
  value = aws_organizations_account.new_account.id
}

output "org_account_ops_role_arn" {
  description = "value"
  value = "arn:aws:iam::${aws_organizations_account.new_account.id}:role/${var.new_account_org_role_name}"
}