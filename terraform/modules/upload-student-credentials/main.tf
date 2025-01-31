locals {
  student_credentials   = var.students_credentials
  bucket_id             = var.bucket
  bucket_path           = var.bucket_path
  credentials_file_name = "codeyou_student_credentials_${var.environment}.json"
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

# Delete the local file after a successful S3 upload
resource "null_resource" "delete_credentials_file" {
  depends_on = [aws_s3_object.credentials_file]

  provisioner "local-exec" {

    command = "rm -f ${path.module}/${local.credentials_file_name}"
  }
}