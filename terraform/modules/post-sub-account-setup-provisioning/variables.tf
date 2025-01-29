variable "dynamic_dashboard_updater_lambda_arn" {
  type = string
  description = "The ARN of the lambda function that dynamically updates the cloudwatch dashboard"
}

variable "dynamic_dashboard_updater_lambda_name" {
  type = string
  description = "The name of the dynamic dashboard updated lambda function"
}

variable "lambda_function_region" {
  type = string
  description = "The region where the lambda function is located at."
}

variable "organization_id" {
  type = string
  description = "The Organization ID"
}
