terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.management_account]
    }
  }
}

locals {
  student_role_name = var.student_role_name
  student_group_name = var.student_group_name
}

resource "aws_iam_role" "student_role" {
  name               = local.student_role_name
  assume_role_policy = data.aws_iam_policy_document.student_trust_policy.json

  tags = {
    Environment = "Student Cohort"
    RoleType    = "Student"
  }
}


resource "aws_iam_role_policy" "student_role_permissions_policy" {
  name   = "CodeYouStaffStudentPolicy"
  role   = aws_iam_role.student_role.id
  policy = data.aws_iam_policy_document.student_owner_permission_policy.json
}

resource "aws_iam_policy" "student_owner_managed_policy" {
  name        = "StudentOwnerManagedPolicy"
  description = "Permissions for students"
  policy      = data.aws_iam_policy_document.student_owner_permission_policy.json
}

resource "aws_iam_policy_attachment" "student_owner_policy_attach" {
  name       = "attach-student-group-policy"
  policy_arn = aws_iam_policy.student_owner_managed_policy.arn
  groups     = [
    local.student_group_name
  ]
}

resource "aws_iam_policy" "student_ec2_managed_policy" {
  name        = "StudentEc2ManagedPolicy"
  description = "Permissions for students"
  policy      = data.aws_iam_policy_document.student_ec2_permission_policy.json
}

resource "aws_iam_policy_attachment" "student_ec2_policy_attach" {
  name       = "attach-student-ec2-group-policy"
  policy_arn = aws_iam_policy.student_ec2_managed_policy.arn
  groups     = [
    local.student_group_name
  ]
}

resource "aws_iam_policy" "student_ecs_managed_policy" {
  name        = "StudentECSManagedPolicy"
  description = "Permissions for students"
  policy      = data.aws_iam_policy_document.student_ecs_and_project_permission_policy.json
}

resource "aws_iam_policy_attachment" "student_ecs_policy_attach" {
  name       = "attach-student-ecs-group-policy"
  policy_arn = aws_iam_policy.student_ecs_managed_policy.arn
  groups     = [
    local.student_group_name
  ]
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "DevOpsClassECSInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
}

resource "aws_iam_policy" "ecs_instance_policy" {
  name   = "DevOpsClassECSInstancePolicy"
  policy = data.aws_iam_policy_document.ecs_instance_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.ecs_instance_policy.arn
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "DevOpsClassECSInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

