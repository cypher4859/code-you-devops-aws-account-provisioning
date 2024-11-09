// Create the OIDC audience
// Create the deploy role that github will use

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
locals {
    github_actions_role_name       = "CodeYouGithubActionsRole"
    github_repo                    = var.github_repo
}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repo}:ref:refs/heads/develop"]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github_actions" {
    url = "https://token.actions.githubusercontent.com"

    client_id_list = ["sts.amazonaws.com"]

    # This is the SHA-1 thumbprint of the certificate used by https://token.actions.githubusercontent.com, 
    # which GitHub uses to issue OIDC tokens.
    # If needed you can use the `openssl` CLI tool to check certificate chain of the OIDC endpoint
    thumbprint_list = [
      "6938fd4d98bab03faadb97b34396831e3780aea1",
      "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
    ]
}

resource "aws_iam_role" "github_actions_role" {
    name               = local.github_actions_role_name
    assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json

    tags = {
        Environment = "Student Cohort"
        RoleType    = "GithubActionsRole"
    }
}

# TODO: The permissions in this policy need to change
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
    role       = aws_iam_role.github_actions_role.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # Adjust as necessary for desired permissions
}