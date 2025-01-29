output "subaccount_observability_role_arn" {
    description = "The Role in the subaccount that's used for the root account to monitor"
    value = aws_iam_role.cloudwatch_observability_role.arn
}