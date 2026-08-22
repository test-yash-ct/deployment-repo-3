resource "aws_s3_bucket" "reporting_exports" {
  bucket = "healthops-reporting-exports-${var.aws_region}"
}

resource "aws_s3_bucket_public_access_block" "reporting_exports" {
  bucket                  = aws_s3_bucket.reporting_exports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reporting_exports" {
  bucket = aws_s3_bucket.reporting_exports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_ownership_controls" "reporting_exports" {
  bucket = aws_s3_bucket.reporting_exports.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
