data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "student_ecs_and_project_permission_policy" {
  # 1) ALLOW creating ECS resources if they pass a tag 'Owner = ${aws:username}'
  statement {
    sid    = "CreateEcsResourcesWithOwnerTag"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:RunTask"
    ]
    resources = ["*"]

    # The key part: require they set Owner = their username on creation
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid     = "CreateCluster"
    effect = "Allow"
    actions = [
      "ecs:Create*",
      "ecs:RegisterTaskDefinition",
      "ecs:PutClusterCapacityProviders"

    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowTagResourceOnCreateActions"
    effect = "Allow"
    actions = [
      "ecs:TagResource"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ecs:CreateAction"
      values   = [
        "CreateCluster",
        "CreateCapacityProvider",
        "CreateService",
        "CreateTaskSet",
        "RegisterContainerInstance",
        "RegisterTaskDefinition",
        "RunTask",
        "StartTask"
      ]
    }
  }


  # 2) ALLOW manage/update ECS resources (clusters, services, tasks, etc.)
  #    only if the resource is tagged with Owner = ${aws:username}
  statement {
    sid    = "ManageOwnEcsResources"
    effect = "Allow"
    actions = [
      "ecs:DeleteCluster",
      "ecs:DeregisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:DeleteService",
      "ecs:StopTask",
      # Possibly you want them to be able to run tasks on an existing service, etc.
      "ecs:RunTask"
      # For demonstration, add whatever ECS actions they need to 'manage' resources.
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ecs:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  # 3) (OPTIONAL) ALLOW read-only ECS if you want them to describe all ECS resources
  statement {
    sid    = "EcsReadOnly"
    effect = "Allow"
    actions = [
      "ecs:List*",
      "ecs:Describe*",
      "servicediscovery:List*"
      # This might let them see other clusters or services. 
      # If you only want them to see their own, skip or scope it with conditions.
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadOnlyMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*",
      "cloudwatch:ListDashboards",
      "cloudwatch:GetDashboard",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadOnlyLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowCloudFormationOperations"
    effect  = "Allow"
    actions = [
        "cloudformation:CreateStack",
        "cloudformation:UpdateStack",
        "cloudformation:DeleteStack",
        "cloudformation:Describe*",
        "cloudformation:List*",
        "cloudformation:GetTemplate",
        "cloudformation:ValidateTemplate",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowECSIntegration"
    effect = "Allow"
    actions = [
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:UpdateContainerInstancesState",
        "ecs:Submit*",
        "ecs:TagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowSSM"
    effect  = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = ["*"]
  }

  statement {
    sid   = "AllowUntaggingOnOwnersStuff"
    effect = "Allow"
    actions = [
      "ecs:UntagResource"
    ]
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "ecs:ResourceTag/Owner"
      values   = ["$${aws:username}"]
    }
  }

  statement {
    sid     = "AddServiceCreationPermissions"
    effect  = "Allow"
    actions  = [
      "iam:CreateServiceLinkedRole",
      "sns:CreateTopic",
      "sns:Subscribe",
      "sns:Get*",
      "sns:List*"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowALB"
    effect  = "Allow"
    actions = [
      "elasticloadbalancing:RegisterTargets ",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:RegisterTargets",
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowALBOwner"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:DeregisterTargets"
    ]
    
    resources = ["*"]
  }
}

