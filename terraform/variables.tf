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

# variable "billing_json" {
#   type = string
#   description = "JSON data for Billing staff in the Billing Account"
# }

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
  description = "value"
}