
# Create an S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "my-cloudtrail-logs-${random_string.suffix.result}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true # Prevent accidental deletion of the bucket
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Add bucket policy for CloudTrail to write logs
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:GetBucketAcl",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}"
      },
      {
        Sid       = "AWSCloudTrailWrite",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Generate a random string for bucket uniqueness
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Create the CloudTrail
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "my-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  s3_key_prefix                 = "cloudtrail-logs"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  is_organization_trail         = false # Set to true if you want to apply it to all accounts in your AWS Organization
}

# Enable logging
resource "aws_cloudtrail_event_selector" "management_events" {
  trail_name = aws_cloudtrail.cloudtrail.name

  event_selector {
    read_write_type = "All" # Options: ReadOnly, WriteOnly, All
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}/"
      ]
    }
  }
}
