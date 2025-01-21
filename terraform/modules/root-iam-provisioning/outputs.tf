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

output "managememnt_admin_role_name" {
    description = "Administrator role name in the root account"
    value = aws_iam_role.cross_account_staff_administrators_role.id
}

output "management_admin_cross_account_role_arn" {
    description = "The CrossAccount Admin Role in the Root Account"
    value = aws_iam_role.cross_account_staff_administrators_role.arn
}

output "management_billing_role_arn" {
    description = "Billing Role ARN in the Management Account"
    value = aws_iam_role.staff_billing_role.arn
}

output "management_admin_iam_users" {
    description = "The list of IAM Admin users."
    value = {
        for user_key, user in aws_iam_user.admin_user :
        user.name => {
            arn         = user.arn
            name        = user.name
            email       = local.administrators[user_key].email
            tags        = user.tags
        }
    }
    sensitive = true
}