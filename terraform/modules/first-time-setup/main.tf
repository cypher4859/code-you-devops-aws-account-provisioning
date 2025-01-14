data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "primary_bucket" {
  bucket = var.bucket_id
}

locals {
    account_id = data.aws_caller_identity.current.account_id
    student_new_users_output_json_file_name = "students.json"
    
    student_new_users_csv_path = "environment/aws/management/data-uploads/roster/csv/students/"
    student_new_users_json_path = "environment/aws/management/data-uploads/roster/json/students/"
    student_bucket_path_to_csv_file = "${local.student_new_users_csv_path}students.csv"

    mentor_new_users_csv_path = "environment/aws/management/data-uploads/roster/csv/mentors/"
    mentor_new_users_json_path = "environment/aws/management/data-uploads/roster/json/mentors/"
    mentor_bucket_path_to_csv_file = "${local.mentor_new_users_csv_path}mentors.csv"

    bucket = data.aws_s3_bucket.primary_bucket
    github_repo = var.github_repo
    github_token = var.github_token
    target_workflow = var.target_workflow
}

module "setup-pipeline-access" {
    source = "../github-role-setup"
    account_id = local.account_id
    github_repo = local.github_repo
    environment = var.environment
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_trigger_role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Action : "sts:AssumeRole"
        Effect : "Allow"
        Principal : {
          Service : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name = "lambda_s3_read_policy"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource : [
          local.bucket.arn,
          "${local.bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# FIXME: This will end up being a reusable module for mentors as well
module "setup-lambda-csv-to-json" {
  source = "./lambda-parse-csv-to-json-and-notifications"
  bucket = local.bucket
  lambda_execution_role = aws_iam_role.lambda_role
  json_s3_bucket_prefix_file_name = local.student_new_users_json_path
  csv_s3_bucket_prefix_file_name = local.student_bucket_path_to_csv_file
  csv_directory_s3_bucket_prefix = local.student_new_users_csv_path
  json_directory_s3_bucket_prefix = local.student_new_users_json_path
  output_json_file_name = local.student_new_users_output_json_file_name
  depends_on = [ aws_iam_role_policy_attachment.lambda_logging_policy ]
}

module "setup-lambda-trigger-github-workflow" {
  source = "./lambda-trigger-github-workflow"
  github_token = local.github_token
  github_repo = local.github_repo
  target_workflow = local.target_workflow
  lambda_execution_role = aws_iam_role.lambda_role
  bucket_arn = local.bucket.arn
}

resource "aws_s3_bucket_notification" "handle_bucket_notifications" {
  bucket = local.bucket.id

  dynamic "lambda_function" {
    for_each = [
      # Lambda setup for notify github on student json upload
      {
        lambda_function_arn = module.setup-lambda-csv-to-json.lambda_function_arn
        filter_prefix       = local.student_new_users_csv_path
        filter_suffix       = ".csv"
      },
      # Lambda setup for notify github on lambda-parse-csv-to-json upload
      {
        lambda_function_arn = module.setup-lambda-trigger-github-workflow.lambda_function_arn
        filter_prefix       = local.student_new_users_json_path
        filter_suffix       = ".json"
      }
    ]
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = ["s3:ObjectCreated:*", "s3:ObjectRestore:Post"]

      filter_prefix = lambda_function.value.filter_prefix
      filter_suffix = lambda_function.value.filter_suffix
    }
  }

  depends_on = [
    module.setup-lambda-trigger-github-workflow, 
    module.setup-lambda-csv-to-json
  ]
}