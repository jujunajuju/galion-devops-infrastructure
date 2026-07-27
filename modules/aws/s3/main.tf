resource "aws_s3_bucket" "bucket" {

  bucket = "${var.project_name}-${var.environment}-bucket"

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
  }

}


resource "aws_s3_bucket" "logs" {

  bucket = "${var.project_name}-${var.environment}-logs"

  tags = {
    Name        = "${var.project_name}-${var.environment}-logs"
    Environment = var.environment
  }

}


resource "aws_s3_bucket_logging" "bucket_logging" {

  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.logs.id

  target_prefix = "access-logs/"

}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_versioning" "bucket_versioning" {

  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }

}