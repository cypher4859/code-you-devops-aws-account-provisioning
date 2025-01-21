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

variable "staff_billing_role_name" {
    default = "CodeYou_Staff_Billing_Role"
    type = string
    description = "The name of the child account billing role"
}

variable "staff_administrators_role_name" {
    default = "CodeYou_Staff_Administrators_Role"
    type = string
    description = "The name of the child account administrators role"
}

variable "mentor_role_name" {
    default = "CodeYou_Mentor_Role"
    type = string
    description = "The name of the child account mentor role role"
}

variable "student_role_name" {
    default = "CodeYou_Student_Role"
    type = string
    description = "The name of the child account student role"
}

variable "management_admin_group_arn" {
    type = string
}

variable "root_account_staff_admin_users" {
    description = "The list of admin users that the subaccount admin role will trust"
    type = list
}
