resource "random_uuid" "bucket_name" {}

resource "aws_s3_bucket" "webapp_s3" {
  bucket        = "webapp-${random_uuid.bucket_name.result}"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "${var.name_prefix}-webapp-s3"
    Environment = var.environment
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "webapp_s3_public_access" {
  bucket = aws_s3_bucket.webapp_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.webapp_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle policy: Move to STANDARD_IA after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.webapp_s3.id

  rule {
    id     = "move-to-IA"
    status = "Enabled"

    filter {
      prefix = "" # Applies to all objects
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
