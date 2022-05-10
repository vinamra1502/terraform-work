variable "s3_bucket_name" {
  description = "Name of the S3 bucket name."
  type        = string
}

variable "acl_type" {
  description = "Specify the Acl type for bucket."
  type        = string
}
variable "environment" {
  default = "dev"
}

variable "lifecycle_enable" {
  default = "false"
}
variable "cors_enable" {
  default = "false"
}
