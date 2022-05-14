module "s3_bucket" {
  source  = "../../../terraform-module/s3/"
  s3_bucket_name               = "lessen-photo-bucket"
  environment                  =  var.environment
  acl_type                     = "private"
  enable_versioning            = "true"
  enable_encryption            = "true"
  enable_cors                  = "true"
  cors_rule_inputs         = [
    {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = [var.environment != "dev" ? var.cors_origin1 : var.cors_origin2]
  },
]
}
module "s3_bucket_two" {
  source  = "../../../terraform-module/s3/"
  s3_bucket_name               = "netsuite-backup-bucket"
  environment                  = "dev"
  acl_type                     = "private"
  enable_versioning            = "true"
  enable_encryption            = "true"
  enable_lifecycle             = "true"
  lifecycle_expiration_days    = "90"
}
