

module "roles_and_permissions" {
    source = "./sub_account_roles_and_permissions"
}

module "users_and_groups" {
    source = "./sub_account_users_and_groups"
}