terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

# FIXME: This needs turned back on for a fresh account
# resource "aws_organizations_organization" "root_org" {
#   feature_set = "ALL"
# }

data "aws_organizations_organization" "root_org" {}

# TODO: Need to fill out the SCP
resource "aws_organizations_policy" "root_scp" {
  name        = "DenyCertainServices"
  description = "Deny access to certain services for member accounts"
  content     = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Action": [
          "ec2:RunInstances"
        ],
        "Resource": "*"
      }
    ]
  })
  type = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "root_attachment" {
  policy_id = aws_organizations_policy.root_scp.id
  target_id = data.aws_organizations_organization.root_org.roots[0].id
}