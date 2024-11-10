locals {
  bucket = var.bucket
  lambda_execution_role = var.lambda_execution_role
  json_s3_bucket_prefix_file_name = var.json_s3_bucket_prefix_file_name
  csv_s3_bucket_prefix_file_name = var.csv_s3_bucket_prefix_file_name
  csv_directory_s3_bucket_prefix = var.csv_directory_s3_bucket_prefix
  json_directory_s3_bucket_prefix = var.json_directory_s3_bucket_prefix
  output_json_file_name = var.output_json_file_name
}

data "archive_file" "lambda_csv_to_json_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/code" # Replace with your directory path
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_s3_object" "csv_target_prefix" {
  bucket = local.bucket.id
  key    = local.csv_directory_s3_bucket_prefix
}

resource "aws_s3_object" "json_destination_prefix" {
  bucket = local.bucket.id
  key    = local.json_directory_s3_bucket_prefix
}

resource "aws_lambda_function" "s3_trigger_convert_csv_to_json" {
  function_name = "ConvertCSVToJsonOnS3Upload"
  role          = local.lambda_execution_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"  # or use any runtime you prefer
  timeout       = 30
  filename      = data.archive_file.lambda_csv_to_json_lambda_zip.output_path

  # Environment variables (optional)
  environment {
    variables = {
      TARGET_BUCKET = local.bucket.id
      CSV_ROSTER_FILE_BUCKET_KEY = local.csv_s3_bucket_prefix_file_name # Points directly at file
      JSON_ROSTER_FILE_PREFIX = local.json_s3_bucket_prefix_file_name # points at the prefix, should end in `/`
      OUTPUT_JSON_FILE_NAME = local.output_json_file_name # Simply the name of the file
    }
  }
}

resource "aws_lambda_permission" "allow_s3_bucket_trigger_convert_csv" {
  statement_id  = "AllowS3InvokeLambdaTriggerConvertCsv"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_convert_csv_to_json.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.bucket.arn
}
