
variable "environment" {
  default = "dev"
}
variable "cluster_vertical" {
  default = ""
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
  default     = "172.20.0.0/16"
}
variable "private_subnets_cidr" {
  type        = list
  description = "CIDR block for Private Subnet"
  default     = ["172.20.16.0/20", "172.20.32.0/20", "172.20.48.0/20"]
}

variable "source_identifier" {
  type        = list(string)
  default     = ["ACM_CERTIFICATE_EXPIRATION_CHECK","CLOUDFRONT_ORIGIN_ACCESS_IDENTITY_ENABLED","CLOUDFRONT_SNI_ENABLED","CLOUDFRONT_VIEWER_POLICY_HTTPS","CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED",
  "CLOUD_TRAIL_ENABLED","CLOUD_TRAIL_ENCRYPTION_ENABLED","CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED","CLOUDTRAIL_SECURITY_TRAIL_ENABLED","CODEBUILD_PROJECT_ENVVAR_AWSCRED_CHECK",
  "CODEBUILD_PROJECT_SOURCE_REPO_URL_CHECK","IAM_PASSWORD_POLICY","IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS","IAM_USER_MFA_ENABLED","MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS",
  "RDS_CLUSTER_DELETION_PROTECTION_ENABLED","RDS_LOGGING_ENABLED","RDS_SNAPSHOT_ENCRYPTED","RDS_ENHANCED_MONITORING_ENABLED","RDS_INSTANCE_PUBLIC_ACCESS_CHECK",
  "RDS_SNAPSHOTS_PUBLIC_PROHIBITED","RDS_STORAGE_ENCRYPTED","ROOT_ACCOUNT_MFA_ENABLED","S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED","S3_BUCKET_VERSIONING_ENABLED","VPC_FLOW_LOGS_ENABLED"]
}
