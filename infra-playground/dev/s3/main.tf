module "s3_bucket" {
  source  = "../../../terraform-module/s3/"
  s3_bucket_name    = "lessen-photo-bucket"
  environment       = "dev"
  acl_type          = "private"
  lifecycle_enable   = "true"
  cors_enable        = "true"
}
