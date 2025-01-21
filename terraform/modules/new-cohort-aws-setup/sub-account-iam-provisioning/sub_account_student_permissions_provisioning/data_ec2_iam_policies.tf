locals {
  student_group_arn     = ""
}

# FIXME: The student group should have a policy attached that allows them to assume the Student Role
# instead of trying to set a condition to the principal tag since groups are not principals
data "aws_iam_policy_document" "student_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:PrincipalTag/Group"
    #   values   = [local.student_group_arn]
    # }
  }
}

data "aws_iam_policy_document" "student_owner_permission_policy" {
  statement {
    sid    = "SQSPermissions"
    effect = "Allow"
    actions = [
      "sqs:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }
  

  statement {
    sid    = "SNSPermissions"
    effect = "Allow"
    actions = [
      "sns:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "S3Permissions"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid      = "ApplicationAutoScalingPermissions"
    effect   = "Allow"
    actions  = [
      "application-autoscaling:*"
    ]
    resources = ["*"]
  }

  statement {
    sid      = "ElasticLoadBalancingPermissions"
    effect   = "Allow"
    actions  = [
      "elasticloadbalancing:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid      = "AutoScalingPermissions"
    effect   = "Allow"
    actions  = [
      "autoscaling:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid = "AutoScalingCreate"
    effect = "Allow"
    actions = [
      "autoscaling:Create*",
      "autoscaling:UpdateAutoScalingGroup"
    ]
    resources = ["*"]
  }

  statement {
    sid      = "ChangePassword"
    effect   = "Allow"
    actions  = ["iam:ChangePassword"]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid       = "AllowCreateRole"
    effect    = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:AttachRolePolicy",
      "iam:ListAttachedRolePolicies"
    ]
    resources = ["*"]
  } 

  statement {
    sid      = "ManageAccessKeys"
    effect   = "Allow"
    actions  = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:UpdateAccessKey",
      "iam:ListAccessKeys"
    ]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid      = "ManageMFADevices"
    effect   = "Allow"
    actions  = [
      "iam:ListMFADevices",
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:ResyncMFADevice"
    ]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid      = "ViewUserDetails"
    effect   = "Allow"
    actions  = ["iam:GetUser"]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid      = "TagManagement"
    effect   = "Allow"
    actions  = [
      "iam:TagUser",
      "iam:UntagUser"
    ]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

}

data "aws_iam_policy_document" "student_ec2_permission_policy" {
  # 1) Allow broad read-only across AWS
  statement {
    sid     = "AllowListingAndDescribing"
    effect  = "Allow"
    actions = [
      "ec2:List*",
      "ec2:Describe*",
      "ec2:Get*",
      "ecs:List*",
      "ecs:Describe*",
      "ecs:Get*",
      "cloudwatch:List*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "logs:List*",
      "logs:Describe*",
      "logs:Get*",
      "logs:Create*",
      "iam:GetRole",
      "iam:ListRoles",
      "iam:ListInstanceProfiles",
      "iam:PassRole",
      "autoscaling:Describe*",
      "autoscaling:List*",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListeners",
      "s3:List*",
      "s3:Get*",
      "ecr:BatchGet*",
      "ecr:BatchCheck*",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "ssm:Get*",
      "ssm:Describe*"
    ]
    resources = ["*"]
  }

  # 2) Allow creating t2.micro or t2.small instances with default tenancy,
  #    but the request must include a tag 'Owner = aws:username'.
  statement {
    sid    = "AllowRunInstancesT2MicroOrSmall"
    effect = "Allow"
    actions = [
      "ec2:RunInstances"
    ]
    resources = ["*"]

    # Restrict instance type
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "ec2:InstanceType"
      values   = ["t2.nano", "t2.micro", "t2.small", "t3.micro"]
    }
  }

  statement {
    sid    = "AllowRunInstancesWithTagging"
    effect = "Allow"
    actions = [
      "ec2:RunInstances"
    ]
    resources = [
      "arn:aws:ec2:*:*:network-interface/*",
      "arn:aws:ec2:*:*:subnet/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:key-pair/*",
      "arn:aws:ec2:*:*:image/*"
    ]
  }

  # 3a) Allow creating/importing key pairs if the request includes
  #     Owner = aws:username
  statement {
    sid    = "CreateImportKeyPairWithOwnerTag"
    effect = "Allow"
    actions = [
      "ec2:CreateKeyPair",
      "ec2:ImportKeyPair"
    ]
    resources = ["*"]
  }

  # 3b) Allow deleting/describing key pairs only if they're tagged with Owner = aws:username
  statement {
    sid    = "DeleteDescribeOwnKeyPairs"
    effect = "Allow"
    actions = [
      "ec2:DeleteKeyPair",
      "ec2:DescribeKeyPairs"
    ]
    resources = ["*"]

    # The key pair resource must have Owner = the user's username
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  # 4) Allow start/stop/terminate *only* on instances tagged with Owner = their username
  statement {
    sid    = "StopStartTerminateOwnInstances"
    effect = "Allow"
    actions = [
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:TerminateInstances"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "CreateSecurityGroupWithOwnerTag"
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid     = "AllowSecurityRuleManagement"
    effect  = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:AllocateAddress",
      "ec2:AssociateAddress"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowTaggingWithOwner"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      # "ec2:DeleteTags"
    ]
    resources = ["*"]

    # Students can only create or delete tags where the Owner matches their username
    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:RequestTag/Owner"
    #   values   = ["$${aws:username}"]
    # }
  }

  statement {
    sid    = "AllowDeletingTagsWithOwner"
    effect = "Allow"
    actions = [
      "ec2:DeleteTags"
    ]
    resources = ["*"]

    # Students can only create or delete tags where the Owner matches their username
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid     = "AllowLaunchTemplateActions"
    effect  = "Allow"
    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:CreateLaunchTemplateVersion",
      "ec2:Describe*",
    ]
    resources = [ "*" ]
  }

  statement {
    sid     = "AllowOnlyOwnerLaunchTemplatesOps"
    effect  = "Allow"
    actions = [
      "ec2:DeleteLaunchTemplate",
      "ec2:DeleteLaunchTemplateVersions",
      "ec2:ModifyLaunchTemplate"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid       = "AllowGlobalLambdaFunction"
    effect    = "Allow"
    actions   = [
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:ListFunctions",
      "lambda:PublishVersion",
      "lambda:TagResource",
      "iam:CreatePolicy",
      "lambda:ListTags",
      "lambda:InvokeFunction",
    ]
    resources = [ "*" ]
  }

  statement {
    sid     = "AllowOnlyOwnerLambdaFunctions"
    effect  = "Allow"
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:DeleteFunction",
      "lambda:AddPermission",
      "lambda:RemovePermission",
    ]
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }
}
