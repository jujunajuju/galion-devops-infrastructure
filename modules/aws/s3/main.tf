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

resource "aws_s3_bucket_versioning" "logs_versioning" {

  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }

}

resource "aws_s3_bucket" "replica" {

  provider = aws.replication

  bucket = "${var.project_name}-${var.environment}-replica"

  tags = {
    Name        = "${var.project_name}-${var.environment}-replica"
    Environment = var.environment
  }

}

resource "aws_s3_bucket_versioning" "replica_versioning" {

  provider = aws.replication

  bucket = aws_s3_bucket.replica.id

  versioning_configuration {
    status = "Enabled"
  }

}

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

      }

    ]

  })

}

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


    destination {

      bucket = aws_s3_bucket.replica.arn

      storage_class = "STANDARD"

    }

  }

}