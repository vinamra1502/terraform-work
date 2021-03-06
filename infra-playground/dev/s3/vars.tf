variable "s3_bucket_name" {
  type    = list(string)
}
variable "environment" {}
variable "acl_type" {}
variable "enable_versioning" {}
variable "enable_encryption" {}
variable "enable_cors" {}
variable "allowed_headers" {}
variable "allowed_methods" {}
variable "enable_lifecycle" {}
variable "lifecycle_expiration_days" {}
variable "cluster_vertical" {}
