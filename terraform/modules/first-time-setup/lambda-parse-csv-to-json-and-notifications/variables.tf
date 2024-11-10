variable "bucket" {
  description = "The bucket"
}

variable "lambda_execution_role" {
  description = "value"
}

variable "json_s3_bucket_prefix_file_name" {
  type = string
  description = "Path in the bucket to the new JSON file"
}

variable "csv_s3_bucket_prefix_file_name" {
  type = string
  description = "Path in the bucket to the CSV file"
}

variable "csv_directory_s3_bucket_prefix" {
  type = string
  description = "The path in to bucket to the folder/directory containing all the CSV files"
}

variable "json_directory_s3_bucket_prefix" {
  type = string
  description = "The path in to bucket to the folder/directory containing all the JSON files"
}


variable "output_json_file_name" {
  type = string
  description = "Location in the bucket that we're going to put the JSON file. This also triggers bucket notifications on upload."
}