data "aws_caller_identity" "current" {}


# Clé KMS région principale pour les buckets S3

resource "aws_kms_key" "s3" {

  description = "KMS key for S3 bucket encryption"

  enable_key_rotation = true

}


# Bucket principal

resource "aws_s3_bucket" "bucket" {

  bucket = "${var.project_name}-${var.environment}-bucket"

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
  }

}


# Chiffrement KMS bucket principal

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {

  bucket = aws_s3_bucket.bucket.id

  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = aws_kms_key.s3.arn

      sse_algorithm = "aws:kms"

    }

  }

}



# Bucket logs

resource "aws_s3_bucket" "logs" {

  bucket = "${var.project_name}-${var.environment}-logs"

  tags = {
    Name        = "${var.project_name}-${var.environment}-logs"
    Environment = var.environment
  }

}



# Chiffrement KMS bucket logs

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {

  bucket = aws_s3_bucket.logs.id

  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = aws_kms_key.s3.arn

      sse_algorithm = "aws:kms"

    }

  }

}



# Blocage accès public logs

resource "aws_s3_bucket_public_access_block" "logs_public_access_block" {

  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}



# Logs du bucket principal

resource "aws_s3_bucket_logging" "bucket_logging" {

  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.logs.id

  target_prefix = "access-logs/"

}



# Blocage accès public bucket principal

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}



# Versioning bucket principal

resource "aws_s3_bucket_versioning" "bucket_versioning" {

  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {

    status = "Enabled"

  }

}



# Versioning logs

resource "aws_s3_bucket_versioning" "logs_versioning" {

  bucket = aws_s3_bucket.logs.id

  versioning_configuration {

    status = "Enabled"

  }

}



# Clé KMS région réplication

resource "aws_kms_key" "s3_replica" {

  provider = aws.replication

  description = "KMS key for S3 replica encryption"

  enable_key_rotation = true

}



# Bucket réplica

resource "aws_s3_bucket" "replica" {

  provider = aws.replication


  bucket = "${var.project_name}-${var.environment}-replica"


  tags = {

    Name = "${var.project_name}-${var.environment}-replica"

    Environment = var.environment

  }

}



# Chiffrement bucket replica

resource "aws_s3_bucket_server_side_encryption_configuration" "replica_encryption" {

  provider = aws.replication


  bucket = aws_s3_bucket.replica.id


  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = aws_kms_key.s3_replica.arn

      sse_algorithm = "aws:kms"

    }

  }

}



# Versioning replica

resource "aws_s3_bucket_versioning" "replica_versioning" {

  provider = aws.replication


  bucket = aws_s3_bucket.replica.id


  versioning_configuration {

    status = "Enabled"

  }

}



# Rôle IAM réplication S3

resource "aws_iam_role" "s3_replication_role" {

  name = "${var.project_name}-${var.environment}-s3-replication-role"


  assume_role_policy = jsonencode({

    Version = "2012-10-17"


    Statement = [

      {

        Action = "sts:AssumeRole"

        Effect = "Allow"


        Principal = {

          Service = "s3.amazonaws.com"

        }

      }

    ]

  })

}



# Permission réplication

resource "aws_iam_role_policy" "s3_replication_policy" {


  name = "${var.project_name}-${var.environment}-s3-replication-policy"


  role = aws_iam_role.s3_replication_role.id



  policy = jsonencode({


    Version = "2012-10-17"


    Statement = [


      {

        Effect = "Allow"


        Action = [

          "s3:GetReplicationConfiguration",

          "s3:ListBucket"

        ]


        Resource = aws_s3_bucket.bucket.arn

      },


      {

        Effect = "Allow"


        Action = [

          "s3:GetObjectVersion",

          "s3:GetObjectVersionAcl"

        ]


        Resource = "${aws_s3_bucket.bucket.arn}/*"

      },


      {

        Effect = "Allow"


        Action = [

          "s3:ReplicateObject",

          "s3:ReplicateDelete",

          "s3:ReplicateTags"

        ]


        Resource = "${aws_s3_bucket.replica.arn}/*"

      },


      {

        Effect = "Allow"


        Action = [

          "kms:Decrypt",

          "kms:Encrypt",

          "kms:GenerateDataKey"

        ]


        Resource = [

          aws_kms_key.s3.arn,

          aws_kms_key.s3_replica.arn

        ]

      }


    ]

  })

}



# Configuration réplication cross-region

resource "aws_s3_bucket_replication_configuration" "replication" {

  depends_on = [
    aws_s3_bucket_versioning.bucket_versioning,
    aws_s3_bucket_versioning.replica_versioning
  ]

  bucket = aws_s3_bucket.bucket.id

  role = aws_iam_role.s3_replication_role.arn


  rule {

    id = "replication-rule"

    status = "Enabled"


    filter {}


    delete_marker_replication {
      status = "Enabled"
    }


    source_selection_criteria {

      sse_kms_encrypted_objects {
        status = "Enabled"
      }

    }


    destination {

      bucket = aws_s3_bucket.replica.arn

      storage_class = "STANDARD"


      encryption_configuration {

        replica_kms_key_id = aws_kms_key.s3_replica.arn

      }

    }

  }

}