output "bucket_path_to_credentials_file" {
  description = "The key path in the bucket to get the credential file"
  value = aws_s3_object.credentials_file.key
  sensitive = true
}

output "bucket_for_credentials" {
  description = "The bucket that holds the credential file"
  value = data.aws_s3_bucket.bucket.bucket
  sensitive = true
}