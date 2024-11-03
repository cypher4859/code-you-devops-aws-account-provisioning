data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "primary_bucket" {
  bucket = var.bucket_id
}

locals {
    account_id = data.aws_caller_identity.current.account_id
    student_new_users_path = "pipeline_data/provision/new_account/new_users/students/"
    mentor_new_users_path = "pipeline_data/provision/new_account/new_users/mentors/"
    bucket = data.aws_s3_bucket.primary_bucket
}

module "setup-pipeline-access" {
    source = "../github-role-setup"
    account_id = local.account_id
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

module "setup-student-bucket-notifications" {
    source = "./setup-generic-bucket-notifications"
    bucket_id = local.bucket.id
    s3_bucket_notification_target_prefix = local.student_new_users_path
    github_repo = var.github_repo
    github_token = var.github_token
    target_workflow = var.target_workflow
    lambda_execution_role_arn = aws_iam_role.lambda_role.arn
    purpose = "NotifyOnStudentUpload"
}

module "setup-mentor-bucket-notifications" {
    source = "./setup-generic-bucket-notifications"
    bucket_id = local.bucket.id
    s3_bucket_notification_target_prefix = local.mentor_new_users_path
    github_repo = var.github_repo
    github_token = var.github_token
    target_workflow = var.target_workflow
    lambda_execution_role_arn = aws_iam_role.lambda_role.arn
    purpose = "NotifyOnMentorUpload"
}

module "setup-lambda-csv-to-json" {
    source = "./lambda-parse-csv-to-json-and-notifications"
    bucket = local.bucket
    lambda_execution_role = aws_iam_role.lambda_role
}
