locals {
  github_repo = var.github_repo
  github_token = var.github_token
  target_workflow = var.target_workflow
  lambda_execution_role = var.lambda_execution_role
  bucket_arn = var.bucket_arn
}

data "archive_file" "trigger_github_workflow_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/code" # Replace with your directory path
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "s3_trigger_github_workflow" {
  function_name = "GithubWorkflowTriggerFullTerraformDeploy"
  role          = local.lambda_execution_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"  # or use any runtime you prefer
  timeout       = 30
  filename      = data.archive_file.trigger_github_workflow_lambda_zip.output_path

  # Environment variables (optional)
  environment {
    variables = {
      GITHUB_TOKEN = local.github_token
      GITHUB_REPO = local.github_repo
      TARGET_WORKFLOW = local.target_workflow
    }
  }
}


resource "aws_lambda_permission" "allow_s3_bucket_trigger_github_workflow" {
  statement_id  = "AllowS3InvokeLambdaTriggerGithubWorkflow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_github_workflow.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.bucket_arn
}

