resource "aws_s3_bucket" "this" {
   bucket = var.s3_bucket_name


  tags = {
      Environment          = var.environment
      Created_by_terraform = true
      Team                 = var.cluster_vertical
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket           = aws_s3_bucket.this.id
  depends_on       = [aws_s3_bucket.this]
  count            = "${var.enable_lifecycle == "true" ? 1 : 0}"

  rule {
    id = "log"

    expiration {
      days = var.lifecycle_expiration_days
    }

    status = "Enabled"
      }
 }



resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket.this]
  count            = "${var.enable_cors == "true" ? 1 : 0}"
  cors_rule {
    allowed_headers = var.allowed_headers
    allowed_methods = var.allowed_methods
    allowed_origins = var.environment != "dev" ? [element(var.allowed_origins,0)]: [element(var.allowed_origins,1)]

    }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket.this]
  acl    = var.acl_type
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  count            = "${var.enable_versioning == "true" ? 1 : 0}"
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  count            = "${var.enable_encryption == "true" ? 1 : 0}"
  depends_on = [aws_s3_bucket.this]
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket.this]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
