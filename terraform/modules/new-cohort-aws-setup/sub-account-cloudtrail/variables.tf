variable "environment" {
  type = string
  description = "The environment that we're deploying into, it should be the root account."
}

variable "subaccount_cloudtrail_bucket_name" {
  type = string
  description = "The name of the S3 bucket that we'll store Cloudtrail logs in"
  default = "codeyou-student-account-cloudtrail-logs"
}
