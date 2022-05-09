resource "aws_s3_bucket" "this" {
   bucket = var.s3_bucket_name
   acl = var.acl_type
   dynamic "cors_rule" {
    for_each = var.cors_rule_inputs == null ? [] : var.cors_rule_inputs

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      # allowed_origins = cors_rule.value.allowed_origins
      allowed_origins = cors_rule.value.allowed_origins

    }
  }
   dynamic "lifecycle_rule" {
      for_each = var.lifecycle_rule_inputs == null ? [] : var.lifecycle_rule_inputs

      content {
        id                                     = lifecycle_rule.value.id
        prefix                                 = lifecycle_rule.value.prefix
        tags                                   = lifecycle_rule.value.tags
        enabled                                = lifecycle_rule.value.enabled
        abort_incomplete_multipart_upload_days = lifecycle_rule.value.abort_incomplete_multipart_upload_days

        dynamic "expiration" {
          for_each = lifecycle_rule.value.expiration_inputs == null ? [] : lifecycle_rule.value.expiration_inputs

          content {
            date                         = expiration.value.date
            days                         = expiration.value.days
            expired_object_delete_marker = expiration.value.expired_object_delete_marker
          }
        }

        dynamic "transition" {
          for_each = lifecycle_rule.value.transition_inputs == null ? [] : lifecycle_rule.value.transition_inputs

          content {
            date          = transition.value.date
            days          = transition.value.days
            storage_class = transition.value.storage_class
          }
        }
  }

}
tags = {
    Environment = var.environment
  }

}
