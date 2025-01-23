data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  trail_name  = "CodeYou-Trail"
  region      = data.aws_region.current.name
  account_id  = data.aws_caller_identity.current.account_id
  partition   = data.aws_partition.current.partition
}


resource "aws_kms_key" "cloudtrail_key" {
  description             = "KMS key for CloudTrail log encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "CloudTrailKMSKeyPolicy",
    Statement = [
      {
        Sid       = "AllowRootAccountFullAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:${local.partition}:iam::${local.account_id}:root"
        },
        Action    = "kms:*",
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudTrailServiceUseOfTheKey",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"
          }
        }
      },
      {
        Sid       = "AllowAccountUseOfKey",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:${local.partition}:iam::${local.account_id}:root"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "cloudtrail_key_alias" {
  name          = "alias/cloudtrail-key"
  target_key_id = aws_kms_key.cloudtrail_key.id
}

# Create an S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = var.cloudtrail_bucket_name

  lifecycle {
    prevent_destroy = true # Prevent accidental deletion of the bucket
  }

  tags = {
    Name        = "CloudTrail Logs Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_bucket" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  rule {
    id      = "log-retention"
    status  = "Enabled"

    expiration {
      days = 90
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_bucket.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_cloudtrail" "CodeYou-Trail" {
  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  s3_key_prefix                 = "AWSLogs"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  is_organization_trail         = true
  kms_key_id                    = aws_kms_key.cloudtrail_key.arn
  

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true
  }

  tags = {
    Name        = "Code:You - Organization CloudTrail"
    Environment = var.environment
  }
}
