variable "s3_bucket_name" {
  description = "Name of the S3 bucket name."
  type        = string
}

variable "acl_type" {
  description = "Specify the Acl type for bucket."
  type        = string
}
variable "environment" {
  default = ""
}

variable "enable_lifecycle" {
  default = "false"
}
variable "enable_cors" {
  default = "false"
}
variable "lifecycle_expiration_days" {
  default = "90"
}

variable "cors_rule_inputs" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)

  }))
  default = null
}
