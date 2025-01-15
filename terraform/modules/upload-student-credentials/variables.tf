variable "bucket" {
  type = string
  description = "The bucket where we will store the student's passwords in the root account."
}

variable "students_credentials" {
  description   = "The student's credentials"
}

variable "bucket_path" {
  description = "The path in the bucket where the credentials will be stored"
  type = string
  default = "environment/aws/management/data-uploads/student-credentials/"
}

variable "environment" {
  description = "The environment in which we're operating"
  type = string
}