
output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail_bucket.id
}