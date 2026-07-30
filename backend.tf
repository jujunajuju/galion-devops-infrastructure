resource "aws_kms_key" "terraform_state" {

  description = "KMS key for Terraform state bucket encryption"

  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid = "Enable IAM User Permissions"

        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::867958227579:root"
        }

        Action = "kms:*"

        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-terraform-state-kms"
    Environment = var.environment
  }

}



# ==========================
# Terraform State Bucket
# ==========================

resource "aws_s3_bucket" "terraform_state" {

  bucket = "${var.project_name}-terraform-state"

  tags = {
    Name        = "${var.project_name}-terraform-state"
    Environment = var.environment
  }

}



# Bloquage accès public State

resource "aws_s3_bucket_public_access_block" "terraform_state_public_access_block" {

  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}



# Encryption KMS State

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {

  bucket = aws_s3_bucket.terraform_state.id


  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "aws:kms"

      kms_master_key_id = aws_kms_key.terraform_state.arn

    }

    bucket_key_enabled = true

  }

}



# Versioning State

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {

  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    ignore_changes = [
      versioning_configuration
    ]
  }

}



# Lifecycle State

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle" {

  bucket = aws_s3_bucket.terraform_state.id


  rule {

    id = "cleanup-old-state"

    status = "Enabled"


    filter {}


    noncurrent_version_expiration {

      noncurrent_days = 90

    }


    abort_incomplete_multipart_upload {

      days_after_initiation = 7

    }

  }

}





# ==========================
# Terraform State Logs Bucket
# ==========================

resource "aws_s3_bucket" "terraform_state_logs" {

  bucket = "${var.project_name}-terraform-state-logs"


  tags = {

    Name = "${var.project_name}-terraform-state-logs"

    Environment = var.environment

  }

}



# Bloquage accès public Logs

resource "aws_s3_bucket_public_access_block" "terraform_state_logs_public_access_block" {

  bucket = aws_s3_bucket.terraform_state_logs.id


  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}



# Encryption KMS Logs

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_logs_encryption" {

  bucket = aws_s3_bucket.terraform_state_logs.id


  rule {

    apply_server_side_encryption_by_default {


      sse_algorithm = "aws:kms"

      kms_master_key_id = aws_kms_key.terraform_state.arn

    }


    bucket_key_enabled = true

  }

}



# Versioning Logs

resource "aws_s3_bucket_versioning" "terraform_state_logs_versioning" {

  bucket = aws_s3_bucket.terraform_state_logs.id

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    ignore_changes = [
      versioning_configuration
    ]
  }

}



# Lifecycle Logs

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_logs_lifecycle" {


  bucket = aws_s3_bucket.terraform_state_logs.id


  rule {

    id = "cleanup-old-log-versions"

    status = "Enabled"


    filter {}


    noncurrent_version_expiration {

      noncurrent_days = 90

    }


    abort_incomplete_multipart_upload {

      days_after_initiation = 7

    }

  }

}



# Logs du bucket State

resource "aws_s3_bucket_logging" "terraform_state_logging" {


  bucket = aws_s3_bucket.terraform_state.id


  target_bucket = aws_s3_bucket.terraform_state_logs.id


  target_prefix = "logs/"

}