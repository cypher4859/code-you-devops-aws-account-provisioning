variable "s3_bucket_notification_target_prefix" {
  type = string
}

variable "bucket_id" {
  type = string
  description = "The name of the S3 bucket"
}

variable "github_repo" {
  type = string
  description = "value" #"yourusername/yourrepository"
}

variable "github_token" {
  type = string
  description = "value"
}

variable "target_workflow" {
  type = string
  description = "value"
}

variable "lambda_execution_role_arn" {
  type = string
  description = "value"
}

variable "purpose" {
  type = string
  description = "value"
}

variable "new_users_json_path" {
  type = string
  description = "value"
}