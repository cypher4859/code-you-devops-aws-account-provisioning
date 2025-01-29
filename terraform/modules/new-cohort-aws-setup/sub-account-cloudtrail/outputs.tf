
output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail_bucket.id
}

# Output for Verification
output "cloudtrail_bucket_arn" {
  value = aws_s3_bucket.cloudtrail_bucket.arn
}

output "kms_key_arn" {
  value = aws_kms_key.cloudtrail_key.arn
}