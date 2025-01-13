variable "bucket_id" {
  type = string
  description = "value"
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

variable "environment" {
  type = string
  description = "The environment that we're deploying into"
}