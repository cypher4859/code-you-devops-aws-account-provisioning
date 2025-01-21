locals {
  student_credentials   = var.students_credentials
  bucket_id             = var.bucket
  bucket_path           = var.bucket_path
  credentials_file_name = "codeyou_student_credentials_${var.environment}.json"
  region                = var.region
  ses_email             = var.email
  bucket_path_to_credentials_file = "${local.bucket_path}${local.credentials_file_name}"
}

data "aws_s3_bucket" "bucket" {
    bucket = local.bucket_id
}

# Generate the output as a local JSON file
resource "local_file" "credentials_file" {
  content = jsonencode(local.student_credentials)
  filename = "${path.module}/${local.credentials_file_name}"
}

resource "aws_s3_object" "credentials_file" {
  bucket       = data.aws_s3_bucket.bucket.id
  key          = "${local.bucket_path}${local.credentials_file_name}"
  source       = local_file.credentials_file.filename
  content_type = "application/json"

  depends_on = [local_file.credentials_file]
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

data "archive_file" "lambda_ses_email_users_zip" {
  type        = "zip"
  source_dir  = "${path.module}/code" # Replace with your directory path
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "ses_email_credentials_to_users_lambda" {
  function_name = "SESEmailCredentialsToUsers"
  role          = local.lambda_execution_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"  # or use any runtime you prefer
  timeout       = 30
  filename      = data.archive_file.lambda_ses_email_users_zip.output_path

  # Environment variables (optional)
  environment {
    variables = {
      S3_BUCKET = local.bucket.id
      AWS_REGION = local.region
      SES_VERIFIED_EMAIL = local.ses_email
      S3_BUCKET_PATH_CREDENTIALS_FILE = local.bucket_path_to_credentials_file # points at the prefix, should end in `/`
    }
  }
}

resource "aws_lambda_permission" "allow_ses_email_credentials_to_users" {
  statement_id  = "AllowSesEmailCredentialsToUsers"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ses_email_credentials_to_users_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.bucket.arn
}

# Delete the local file after a successful S3 upload
resource "null_resource" "delete_credentials_file" {
  depends_on = [aws_s3_object.credentials_file]

  provisioner "local-exec" {

    command = "rm -f ${path.module}/${local.credentials_file_name}"
  }
}