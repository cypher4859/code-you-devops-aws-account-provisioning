locals {
  bucket = var.bucket
  lambda_execution_role = var.lambda_execution_role
  destination_prefix_for_new_json_file = var.destination_prefix_for_new_json_file
  bucket_path_to_csv_file = var.bucket_path_to_csv_file
  bucket_path_to_csv_directory = var.bucket_path_to_csv_directory
  output_json_file_name = var.output_json_file_name
}

# Attach a policy to allow the Lambda function to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logging_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = local.lambda_execution_role.name
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/code" # Replace with your directory path
  output_path = "${path.module}/lambda_function.zip"
}

# TODO: Need to fill this out
# Create the Lambda function
resource "aws_lambda_function" "s3_trigger_convert_csv_to_json" {
  function_name = "ConvertCSVToJsonOnS3Upload"
  role          = local.lambda_execution_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"  # or use any runtime you prefer
  timeout       = 30
  filename      = data.archive_file.lambda_zip.output_path

  # Environment variables (optional)
  environment {
    variables = {
      TARGET_BUCKET = local.bucket.id
      CSV_ROSTER_FILE_BUCKET_KEY = local.bucket_path_to_csv_file # Points directly at file
      JSON_ROSTER_FILE_PREFIX = local.destination_prefix_for_new_json_file # points at the prefix, should end in `/`
      OUTPUT_JSON_FILE_NAME = local.output_json_file_name # Simply the name of the file
    }
  }

  # Bucket permissions for the Lambda function
  depends_on = [aws_iam_role_policy_attachment.lambda_logging_policy]
}

# Grant permissions for the S3 bucket to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_bucket" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_convert_csv_to_json.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.bucket.arn
}

# Set up an S3 bucket notification to trigger the Lambda
resource "aws_s3_bucket_notification" "example_bucket_notification" {
  bucket = local.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_trigger_convert_csv_to_json.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRestore:Post"]

    # Optional - filter the objects that will trigger the Lambda
    filter_prefix = local.bucket_path_to_csv_directory
    filter_suffix = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_bucket]
}