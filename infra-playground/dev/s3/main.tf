variable "cors_environment" {
  default = "dev"
}

module "s3_bucket" {
  source  = "../../../terraform-module/s3/"
  s3_bucket_name    = "lessen-photo-bucket"
  environment       = "dev"
  acl_type          = "private"
  cors_rule_inputs         = [
    {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = [var.cors_environment != "dev" ? "https://*.lessen.com" : "http://localhost"]
  },
]
lifecycle_rule_inputs = [{
   id                                     = "log"
   enabled                                = true
   prefix                                 = "data/"
   abort_incomplete_multipart_upload_days = null
   tags = {
     "rule"      = "backup1"
     "autoclean" = "true"
   }

   expiration_inputs = [{
     days                         = 90
     date                         = null
     expired_object_delete_marker = null
     },
   ]
   transition_inputs                    = []
 },
]

}
