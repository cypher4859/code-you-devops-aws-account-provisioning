output "management_administrators_group_name" {
    value = aws_iam_group.administrators_group.name
}

output "management_admin_group_arn" {
    value = aws_iam_group.administrators_group.arn
}

output "management_admin_role_arn" {
    description = "Administrator role in the Management account"
    value = aws_iam_role.cross_account_staff_administrators_role.arn
}

output "management_billing_role_arn" {
    description = "Billing Role ARN in the Management Account"
    value = aws_iam_role.staff_billing_role.arn
}
