output "lambda_function_arn" {
  value = aws_lambda_function.s3_trigger_convert_csv_to_json.arn
}