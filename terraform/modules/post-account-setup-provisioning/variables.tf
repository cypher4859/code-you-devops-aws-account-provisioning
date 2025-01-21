variable "root_administrators_group_name" {
  type = string
  description = "value"
}

variable "sub_account_id" {
  type = string
  description = "value"
}

variable "sub_account_staff_administrators_role_arn" {
  type = string
  description = "The Administrators role for staff in the Student Account"
}

variable "root_acct_staff_administrators_role_arn" {
  type = string
  description = "The Administrators Role for staff in the Root Account"
}

variable "root_acct_staff_administrators_role_name" {
  type = string
  description = "The Administrators Role for staff in the Root Account"
}