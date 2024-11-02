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