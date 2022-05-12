resource "aws_s3_bucket" "this" {
   bucket = var.s3_bucket_name


  tags = {
      Environment = var.environment
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
  dynamic "cors_rule" {
    for_each = var.enable_cors == false ? [] : var.cors_rule_inputs

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins

    }
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket.this]
  acl    = var.acl_type
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket.this]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
