resource "aws_s3_bucket" "reporting_exports" {
  bucket = "healthops-reporting-exports-${var.aws_region}"

  tags = {
    service_version = var.service_version
    git_sha         = var.git_sha
    build_time      = var.build_time
    purpose         = "reporting-exports"
  }
}

resource "aws_s3_bucket_public_access_block" "reporting_exports" {
  bucket                  = aws_s3_bucket.reporting_exports.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "reporting_exports_read" {
  bucket = aws_s3_bucket.reporting_exports.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.reporting_exports.arn}/*"]
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.reporting_exports]
}

output "reporting_exports_metadata" {
  description = "Service metadata tags on the reporting exports bucket"
  value = {
    bucket          = aws_s3_bucket.reporting_exports.id
    service_version = var.service_version
    git_sha         = var.git_sha
    build_time      = var.build_time
  }
}
