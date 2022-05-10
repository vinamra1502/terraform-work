resource "aws_s3_bucket" "this" {
   bucket = var.s3_bucket_name


  tags = {
      Environment = var.environment
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket.this]
  count            = "${var.lifecycle_enable == "true" ? 1 : 0}"

  rule {
    id = "log"

    expiration {
      days = 90
    }

    status = "Enabled"
      }
 }

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket.this]
  count            = "${var.cors_enable == "true" ? 1 : 0}"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = [var.environment != "dev" ? "https://*.lessen.com" : "http://localhost"]

  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket.this]
  acl    = var.acl_type
}
