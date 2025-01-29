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
    sid    = "SQSCreationAndRead"
    effect = "Allow"
    actions = [
      "sqs:CreateQueue",
      "sqs:ListQueues",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:TagQueue",
      "sqs:UntagQueue"
    ]
    resources = ["*"]
}

  statement {
    sid    = "SQSUpdateAndDelete"
    effect = "Allow"
    actions = [
      "sqs:DeleteQueue",
      "sqs:SetQueueAttributes",
    ]
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }
  

  statement {
    sid    = "SNSCreateAndRead"
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:ListTopics",
      "sns:GetTopicAttributes",
      "sns:ListTagsForResource",
      "sns:Subscribe",
      "sns:TagResource",
      "sns:UntagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SNSUpdateAndDelete"
    effect = "Allow"
    actions = [
      "sns:DeleteTopic",
      "sns:SetTopicAttributes",
    ]
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
}

  statement {
    sid    = "S3ReadAndCreate"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:GetBucketPolicyStatus",
      "s3:GetBucketTagging",
      "s3:GetObjectTagging",
      "s3:GetLifecycleConfiguration",
      "s3:PutObject",
      "s3:CreateBucket",
      "s3:PutObjectTagging",
      "s3:DeleteObjectTagging",
      "s3:PutBucketAcl",
      "s3:PutBucketPolicy",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutBucketLogging",
      "s3:PutLifecycleConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:DeleteObject",
      "s3:DeleteBucket"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3UpdateAndDelete"
    effect = "Allow"
    actions = [
      "s3:DeleteBucket",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "ELBReadAndCreate"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:AddTags"
    ]
    resources = ["*"]
}

  statement {
    sid    = "ELBUpdateAndDelete"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteTargetGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }


  statement {
    sid    = "AutoScalingReadAndCreate"
    effect = "Allow"
    actions = [
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:DescribeScalingActivities"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AutoScalingUpdateAndDelete"
    effect = "Allow"
    actions = [
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:UpdateScalableTarget"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Owner"
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
      "s3:PutEncryptionConfiguration",
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
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid    = "DeleteSecurityGroupWithOwnerTag"
    effect = "Allow"
    actions = [
      "ec2:DeleteSecurityGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Owner"
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
      variable = "aws:ResourceTag/Owner"
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
      variable = "aws:ResourceTag/Owner"
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
      variable = "aws:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }
}
