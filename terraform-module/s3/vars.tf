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

# variable "bucket_region" {
#   default = "string"
# }
variable "cors_rule_inputs" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)

  }))
  default = null
}

variable "lifecycle_rule_inputs" {
  type = list(object({
    id                                     = string
    prefix                                 = string
    tags                                   = map(string)
    enabled                                = string
    abort_incomplete_multipart_upload_days = string
    expiration_inputs = list(object({
      date                         = string
      days                         = number
      expired_object_delete_marker = string
    }))
    transition_inputs = list(object({
      date          = string
      days          = number
      storage_class = string
    }))


  }))
  default = null
}
