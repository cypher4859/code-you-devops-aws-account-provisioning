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

module "setup-student-bucket-notifications" {
    source = "./setup-generic-bucket-notifications"
    bucket_id = local.bucket.id
    s3_bucket_notification_target_prefix = local.student_new_users_csv_path
    new_users_json_path = local.student_new_users_json_path
    github_repo = var.github_repo
    github_token = var.github_token
    target_workflow = var.target_workflow
    lambda_execution_role_arn = aws_iam_role.lambda_role.arn
    purpose = "NotifyOnStudentUpload"
}

module "setup-mentor-bucket-notifications" {
    source = "./setup-generic-bucket-notifications"
    bucket_id = local.bucket.id
    s3_bucket_notification_target_prefix = local.mentor_new_users_csv_path
    new_users_json_path = local.mentor_new_users_json_path
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
    destination_prefix_for_new_json_file = local.student_new_users_json_path
    bucket_path_to_csv_file = local.student_bucket_path_to_csv_file
    bucket_path_to_csv_directory = local.student_new_users_csv_path
    output_json_file_name = local.student_new_users_output_json_file_name
}
