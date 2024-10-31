resource "aws_organizations_policy" "example_scp" {
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

resource "aws_organizations_policy_attachment" "example_attachment" {
  policy_id = aws_organizations_policy.example_scp.id
  target_id = aws_organizations_account.new_account.id  # Replace with your target ID
}