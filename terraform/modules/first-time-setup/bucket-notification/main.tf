resource "aws_s3_bucket_notification" "generic_bucket_notification" {
  bucket = var.bucket.id

  dynamic "lambda_function" {
    for_each = var.lambda_notifications
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = ["s3:ObjectCreated:*", "s3:ObjectRestore:Post"]

      filter_prefix = lambda_function.value.filter_prefix
      filter_suffix = lambda_function.value.filter_suffix
    }
  }

  depends_on = [aws_lambda_permission.allow_s3_bucket_trigger_generic]
}