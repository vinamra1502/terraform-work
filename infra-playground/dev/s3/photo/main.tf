module "s3_bucket_lessen" {
  source  = "../../../../terraform-module/s3/"
  s3_bucket_name               = var.s3_bucket_name
  environment                  = var.environment
  acl_type                     = var.acl_type
  enable_versioning            = var.enable_versioning
  enable_encryption            = var.enable_encryption
  enable_cors                  = var.enable_cors
  allowed_headers              = var.allowed_headers
  allowed_methods              = var.allowed_methods
}
