variable "account_id" {
  type = string
  description = "Account ID of the AWS account we need to provision"
}

variable "github_repo" {
  type = string
  description = "Github Repo to authorize"
}

variable "environment" {
  type = string
  description = "The environment that we're deploying into"
}