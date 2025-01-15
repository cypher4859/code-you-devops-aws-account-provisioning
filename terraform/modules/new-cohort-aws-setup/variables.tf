variable "account_name" {
  type = string
  description = "Human readable name to distinguish this account."
}

variable "account_owner_email" {
  type = string
  description = "Email address representing the owner of the new organization account"
}

variable "students_json" {
  type = string
  description = "JSON data for students"
}

variable "management_org_id" {
    type = string
    description = "The Organization ID"
}

variable "management_admin_role_arn" {
    type = string
    description = "The role in the Management account that will assume the child account admin role"
}

variable "management_billing_role_arn" {
    type = string
    description = "The role in the Management account that will assume the child account billing role"
}

 variable "management_admin_group_arn" {
    type = string
 }

#  variable "secretsmanager_secret_id_pgppublickey" {
#     type = string
#     description = "The PGP Public Key used for encrypting passwords"
#     sensitive = true
#  }