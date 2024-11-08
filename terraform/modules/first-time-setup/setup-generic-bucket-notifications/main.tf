locals {
  bucket_id = var.bucket_id
  s3_bucket_prefix = var.s3_bucket_notification_target_prefix
  destination_prefix = var.new_users_json_path
  github_repo = var.github_repo
  github_token = var.github_token
  target_workflow = var.target_workflow
  lambda_execution_role_arn = var.lambda_execution_role_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = local.bucket_id
  eventbridge = true
}

resource "aws_cloudwatch_event_rule" "s3_upload_event_rule" {
  name        = "S3FileUploadTrigger${local.target_workflow}${var.purpose}"
  description = "Trigger GitHub workflow upon S3 file upload."
  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": {
        "name": [local.bucket_id]
      },
      "object": {
        "key": [{"prefix": local.s3_bucket_prefix}]
      }
    }
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/code" # Replace with your directory path
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_s3_object" "target_prefix" {
  bucket = local.bucket_id
  key    = local.s3_bucket_prefix  # The trailing '/' represents a folder
}

resource "aws_s3_object" "destination_prefix" {
  bucket = local.bucket_id
  key    = local.destination_prefix  # The trailing '/' represents a folder
}


resource "aws_lambda_function" "lambda_trigger_github_workflow" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "GitHubTrigger_${local.target_workflow}-${var.purpose}"
  role          = local.lambda_execution_role_arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      GITHUB_TOKEN        = local.github_token
      GITHUB_REPO_NAME    = local.github_repo # GitHub repository details
      GITHUB_WORKFLOW     = local.target_workflow
    }
  }
}

# Grant the Lambda permission to be triggered by EventBridge
resource "aws_cloudwatch_event_target" "eventbridge_lambda_target" {
  rule      = aws_cloudwatch_event_rule.s3_upload_event_rule.name
  arn       = aws_lambda_function.lambda_trigger_github_workflow.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge${var.purpose}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_trigger_github_workflow.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_upload_event_rule.arn
}