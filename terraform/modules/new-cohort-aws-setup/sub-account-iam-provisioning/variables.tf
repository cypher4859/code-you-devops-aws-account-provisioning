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

variable "root_account_staff_admin_users" {
}

# variable "secretsmanager_secret_id_pgppublickey" {
#     type = string
#     description = "The PGP Public Key used for Encrypting Passwords"
#     sensitive = true
# }