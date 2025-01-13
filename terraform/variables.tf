variable "students_json" {
  type = string
  description = "JSON data for students"
}

variable "new_account_name" {
  type = string
}

variable "new_account_owner_email" {
  type = string
}

variable "admins_json" {
  type = string
  description = "JSON data for Administrators in the Management Account"
}

variable "bucket_id" {
  type = string
  description = "value"
}

variable "github_repo" {
  type = string
  description = "Repo where the Workflows exist for adding new users" #"yourusername/yourrepository"
}

variable "github_token" {
  type = string
  description = "value"
  sensitive = true
}

variable "target_workflow" {
  type = string
  description = "The repository_dispatch in the github workflows to trigger"
}

variable "backend_bucket" {
  description = "The name of the s3 bucket used for the terraform state backend"
  type        = string
}

variable "backend_bucket_region" {
  description = "The region that we want to use for bucket backend"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  type = string
  description = "The environment that we're deploying into"
}