resource "aws_s3_bucket" "reporting_exports" {
  bucket = "healthops-reporting-exports-${var.aws_region}"
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
