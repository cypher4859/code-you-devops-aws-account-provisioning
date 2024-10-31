resource "aws_organizations_account" "new_account" {
  name      = var.new_account_name           # Replace with the desired account name
  email     = var.new_account_email_address   # Replace with a unique email address for the new account
  role_name = var.new_account_org_role_name  # Role name to assume for accessing the account
  close_on_deletion = true


  tags = {
    Environment = "Student Cohort"  # Example tag; you can modify or add more tags as needed
  }

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}

