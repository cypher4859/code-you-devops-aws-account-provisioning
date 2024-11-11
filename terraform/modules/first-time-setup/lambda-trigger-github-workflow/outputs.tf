output "lambda_function_arn" {
  value = aws_lambda_function.s3_trigger_github_workflow.arn
}