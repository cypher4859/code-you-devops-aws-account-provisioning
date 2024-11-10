variable "bucket" {
  description = "The bucket"
}

variable "lambda_execution_role" {
  description = "value"
}

variable "destination_prefix_for_new_json_file" {
  type = string
  description = "Path in the bucket to the new JSON file"
}

variable "bucket_path_to_csv_file" {
  type = string
  description = "Path in the bucket to the CSV file"
}

variable "bucket_path_to_csv_directory" {
  type = string
  description = "The path in to bucket to the folder/directory containing all the CSV files"
}

variable "output_json_file_name" {
  type = string
  description = "Location in the bucket that we're going to put the JSON file. This also triggers bucket notifications on upload."
}