module "s3_bucket_netsuite" {
  source  = "../../../../terraform-module/s3/"
  s3_bucket_name               = var.s3_bucket_name
  environment                  = var.environment
  acl_type                     = var.acl_type
  enable_versioning            = var.enable_versioning
  enable_encryption            = var.enable_encryption
  enable_lifecycle             = var.enable_lifecycle
  lifecycle_expiration_days    = var.lifecycle_expiration_days
}
