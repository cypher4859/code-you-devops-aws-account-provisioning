output "management_org_id" {
    description = "Management Account Organization ID"
    value = data.aws_organizations_organization.root_org.roots[0].id
}