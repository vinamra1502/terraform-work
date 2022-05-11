variable "cors_environment" {
  default = "dev"
}
module "s3_bucket" {
  source  = "../../../terraform-module/s3/"
  s3_bucket_name               = "lessen-photo-bucket"
  environment                  = "dev"
  acl_type                     = "private"
  enable_cors                  = "true"
  cors_rule_inputs         = [
    {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = [var.cors_environment != "dev" ? "https://*.innovaccer.com" : "http://localhost"]
  },
]
}
module "s3_bucket_two" {
  source  = "../../../terraform-module/s3/"
  s3_bucket_name               = "lessen-backup-bucket"
  environment                  = "dev"
  acl_type                     = "private"
  enable_lifecycle             = "true"
  lifecycle_expiration_days    = "90"


}
