s3_bucket_name = "lessen-photo-bucket"
environment    = "dev"
acl_type       = "private"
enable_versioning  = "true"
enable_encryption = "true"
enable_cors       = "true"
allowed_headers   = [
  "*",
]
allowed_methods   = [
  "PUT",
  "GET",
]
