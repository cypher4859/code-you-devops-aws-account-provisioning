data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "primary_bucket" {
  bucket = var.bucket_id
}

locals {
    account_id = data.aws_caller_identity.current.account_id
    student_new_users_output_json_file_name = "students.json"
    student_new_users_path = "environment/aws/management/data-uploads/roster/json/students/"
    student_bucket_path_to_csv_file = "${local.student_new_users_path}students.csv"
    mentor_new_users_path = "environment/aws/management/data-uploads/roster/csv/mentors/"
    mentor_bucket_path_to_csv_file = "${local.mentor_new_users_path}mentors.csv"

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

# FIXME: Needs refactored to allow for handling both students and mentors
# which probably includes pulling the path from the bucket notification
module "setup-lambda-csv-to-json" {
    source = "./lambda-parse-csv-to-json-and-notifications"
    bucket = local.bucket
    lambda_execution_role = aws_iam_role.lambda_role
    bucket_path_to_csv_file = local.student_bucket_path_to_csv_file
    destination_prefix_for_new_json_file = local.student_new_users_path
    output_json_file_name = local.student_new_users_output_json_file_name
}
