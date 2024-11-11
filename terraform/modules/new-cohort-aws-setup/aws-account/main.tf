terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

resource "aws_organizations_account" "new_account" {
  name      = var.new_account_name           # Replace with the desired account name
  email     = var.new_account_email_address   # Replace with a unique email address for the new account
  role_name = var.new_account_org_role_name  # Role name to assume for accessing the account
  close_on_deletion = false


  tags = {
    Name          = var.new_account_name
    Environment = "Student Cohort"  # Example tag; you can modify or add more tags as needed
    FreeTierEligible = "Yes"
    AutoTerminate = "False"
    Usage         = "Student"
    CreationDate  = timestamp()
    Project       = "DevOps With AWS" # TODO: This needs passed by variable
    Creator       = "Terraform via Charles Kayser"
    Owner         = var.new_account_email_address
  }

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name, tags]
  }
}

# Add a null resource to introduce a delay after account creation
resource "null_resource" "wait_for_role_propagation" {
  depends_on = [aws_organizations_account.new_account]

  provisioner "local-exec" {
    command = "sleep 60"  # Waits for 60 seconds to let the role propagate
  }
}

