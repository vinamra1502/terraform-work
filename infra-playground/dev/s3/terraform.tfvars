s3_bucket_name =  ["lessen-photo-bucket", "netsuite-backup-bucket"]
# s3_bucket_name_netsuite = "netsuite-backup-bucket"
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
enable_lifecycle  = "true"
lifecycle_expiration_days ="90"
