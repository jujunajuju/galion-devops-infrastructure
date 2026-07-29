data "aws_caller_identity" "current" {}


############################################
# KMS KEY REGION PRINCIPALE
############################################

resource "aws_kms_key" "s3" {

  description = "KMS key for S3 bucket encryption"

  enable_key_rotation = true


  policy = jsonencode({

    Version = "2012-10-17"


    Statement = [

      {

        Sid = "EnableRootPermissions"


        Effect = "Allow"


        Principal = {

          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

        }


        Action = "kms:*"


        Resource = "*"

      },


      {

        Sid = "AllowS3Service"


        Effect = "Allow"


        Principal = {

          Service = "s3.amazonaws.com"

        }


        Action = [

          "kms:Encrypt",

          "kms:Decrypt",

          "kms:GenerateDataKey",

          "kms:DescribeKey"

        ]


        Resource = "*"

      }

    ]

  })

}



############################################
# BUCKET PRINCIPAL
############################################

resource "aws_s3_bucket" "bucket" {

  bucket = "${var.project_name}-${var.environment}-bucket"

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
  }

}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {

  bucket = aws_s3_bucket.bucket.id


  rule {

    id = "lifecycle-rule"

    status = "Enabled"


    filter {}


    transition {

      days = 30

      storage_class = "STANDARD_IA"

    }


    expiration {

      days = 365

    }

  }

}



############################################
# CHIFFREMENT BUCKET PRINCIPAL
############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {

  bucket = aws_s3_bucket.bucket.id


  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = aws_kms_key.s3.arn

      sse_algorithm = "aws:kms"

    }

  }

}



############################################
# BUCKET LOGS REGION PRINCIPALE
############################################

resource "aws_s3_bucket" "logs" {

  bucket = "${var.project_name}-${var.environment}-logs"


  tags = {

    Name = "${var.project_name}-${var.environment}-logs"

    Environment = var.environment

  }

}

resource "aws_s3_bucket" "logs_replica" {

  provider = aws.replication

  bucket = "${var.project_name}-${var.environment}-logs-replica"


  tags = {

    Name = "${var.project_name}-${var.environment}-logs-replica"

    Environment = var.environment

  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_replica_encryption" {

  provider = aws.replication

  bucket = aws_s3_bucket.logs_replica.id


  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = aws_kms_key.s3_replica.arn

      sse_algorithm = "aws:kms"

    }

  }

}

resource "aws_s3_bucket_versioning" "logs_replica_versioning" {

  provider = aws.replication

  bucket = aws_s3_bucket.logs_replica.id


  versioning_configuration {

    status = "Enabled"

  }

}

resource "aws_s3_bucket_replication_configuration" "logs_replication" {

  depends_on = [

    aws_s3_bucket_versioning.logs_versioning,

    aws_s3_bucket_versioning.logs_replica_versioning

  ]


  bucket = aws_s3_bucket.logs.id


  role = aws_iam_role.s3_replication_role.arn


  rule {

    id = "logs-replication-rule"

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

      bucket = aws_s3_bucket.logs_replica.arn

      storage_class = "STANDARD"


      encryption_configuration {

        replica_kms_key_id = aws_kms_key.s3_replica.arn

      }

    }

  }

}



############################################
# CHIFFREMENT LOGS
############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {

  bucket = aws_s3_bucket.logs.id


  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = aws_kms_key.s3.arn

      sse_algorithm = "aws:kms"

    }

  }

}



############################################
# BLOCAGE PUBLIC LOGS
############################################

resource "aws_s3_bucket_public_access_block" "logs_public_access_block" {

  bucket = aws_s3_bucket.logs.id


  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true

}



############################################
# LOGGING BUCKET PRINCIPAL
############################################

resource "aws_s3_bucket_logging" "bucket_logging" {

  bucket = aws_s3_bucket.bucket.id


  target_bucket = aws_s3_bucket.logs.id


  target_prefix = "access-logs/"

}



############################################
# BLOCAGE PUBLIC BUCKET PRINCIPAL
############################################

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {

  bucket = aws_s3_bucket.bucket.id


  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true

}



############################################
# VERSIONING PRINCIPAL
############################################

resource "aws_s3_bucket_versioning" "bucket_versioning" {

  bucket = aws_s3_bucket.bucket.id


  versioning_configuration {

    status = "Enabled"

  }

}



############################################
# VERSIONING LOGS
############################################

resource "aws_s3_bucket_versioning" "logs_versioning" {

  bucket = aws_s3_bucket.logs.id


  versioning_configuration {

    status = "Enabled"

  }

}



############################################
# KMS REGION REPLICA
############################################

resource "aws_kms_key" "s3_replica" {

  provider = aws.replication

  description = "KMS key for S3 replica encryption"

  enable_key_rotation = true


  policy = jsonencode({

    Version = "2012-10-17"


    Statement = [

      {

        Sid = "EnableRootPermissions"


        Effect = "Allow"


        Principal = {

          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

        }


        Action = "kms:*"


        Resource = "*"

      },


      {

        Sid = "AllowS3Replication"


        Effect = "Allow"


        Principal = {

          Service = "s3.amazonaws.com"

        }


        Action = [

          "kms:Encrypt",

          "kms:Decrypt",

          "kms:GenerateDataKey",

          "kms:DescribeKey"

        ]


        Resource = "*"

      }

    ]

  })

}



############################################
# BUCKET REPLICA
############################################

resource "aws_s3_bucket" "replica" {

  provider = aws.replication


  bucket = "${var.project_name}-${var.environment}-replica"


  tags = {

    Name = "${var.project_name}-${var.environment}-replica"

    Environment = var.environment

  }

}

resource "aws_s3_bucket_lifecycle_configuration" "replica_lifecycle" {

  provider = aws.replication

  bucket = aws_s3_bucket.replica.id


  rule {

    id = "cleanup-old-replica-versions"

    status = "Enabled"


    filter {}


    noncurrent_version_expiration {

      noncurrent_days = 90

    }

  }

}



############################################
# BLOCAGE PUBLIC REPLICA
############################################

resource "aws_s3_bucket_public_access_block" "replica_public_access_block" {

  provider = aws.replication


  bucket = aws_s3_bucket.replica.id


  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true

}



############################################
# BUCKET LOGS REPLICA
############################################

resource "aws_s3_bucket" "replica_logs" {

  provider = aws.replication


  bucket = "${var.project_name}-${var.environment}-replica-logs"


  tags = {

    Name = "${var.project_name}-${var.environment}-replica-logs"

    Environment = var.environment

  }

}

resource "aws_s3_bucket_versioning" "replica_logs_versioning" {

  provider = aws.replication

  bucket = aws_s3_bucket.replica_logs.id


  versioning_configuration {

    status = "Enabled"

  }

}

resource "aws_s3_bucket" "replica_logs_backup" {

  provider = aws.replication

  bucket = "${var.project_name}-${var.environment}-replica-logs-backup"


  tags = {

    Name = "${var.project_name}-${var.environment}-replica-logs-backup"

    Environment = var.environment

  }

}

resource "aws_s3_bucket_versioning" "replica_logs_backup_versioning" {

  provider = aws.replication


  bucket = aws_s3_bucket.replica_logs_backup.id


  versioning_configuration {

    status = "Enabled"

  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica_logs_backup_encryption" {

  provider = aws.replication


  bucket = aws_s3_bucket.replica_logs_backup.id


  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = aws_kms_key.s3_replica.arn

      sse_algorithm = "aws:kms"

    }

  }

}

resource "aws_s3_bucket_replication_configuration" "replica_logs_replication" {


  depends_on = [

    aws_s3_bucket_versioning.replica_logs_versioning,
    aws_s3_bucket_versioning.replica_logs_backup_versioning

  ]


  provider = aws.replication


  bucket = aws_s3_bucket.replica_logs.id


  role = aws_iam_role.s3_replication_role.arn


  rule {

    id = "replica-logs-replication-rule"


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

      bucket = aws_s3_bucket.replica_logs_backup.arn


      storage_class = "STANDARD"


      encryption_configuration {

        replica_kms_key_id = aws_kms_key.s3_replica.arn

      }

    }

  }

}


resource "aws_s3_bucket_server_side_encryption_configuration" "replica_logs_encryption" {

  provider = aws.replication

  bucket = aws_s3_bucket.replica_logs.id


  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = aws_kms_key.s3_replica.arn

      sse_algorithm = "aws:kms"

    }

  }

}

resource "aws_s3_bucket_public_access_block" "replica_logs_public_access_block" {

  provider = aws.replication

  bucket = aws_s3_bucket.replica_logs.id


  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true

}

resource "aws_s3_bucket_lifecycle_configuration" "replica_logs_lifecycle" {

  provider = aws.replication

  bucket = aws_s3_bucket.replica_logs.id


  rule {

    id = "cleanup-old-replica-log-versions"

    status = "Enabled"


    filter {}


    noncurrent_version_expiration {

      noncurrent_days = 90

    }

  }

}



############################################
# LOGGING REPLICA
############################################

resource "aws_s3_bucket_logging" "replica_logging" {

  provider = aws.replication


  bucket = aws_s3_bucket.replica.id


  target_bucket = aws_s3_bucket.replica_logs.id


  target_prefix = "replica-access-logs/"

}



############################################
# CHIFFREMENT REPLICA
############################################

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



############################################
# VERSIONING REPLICA
############################################

resource "aws_s3_bucket_versioning" "replica_versioning" {

  provider = aws.replication


  bucket = aws_s3_bucket.replica.id


  versioning_configuration {

    status = "Enabled"

  }

}

############################################
# ROLE IAM POUR REPLICATION S3
############################################

resource "aws_iam_role" "s3_replication_role" {

  name = "${var.project_name}-${var.environment}-s3-replication-role"


  assume_role_policy = jsonencode({

    Version = "2012-10-17"


    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "s3.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}



############################################
# POLICY IAM REPLICATION + KMS
############################################

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

        Resource = [

          aws_s3_bucket.bucket.arn,
          aws_s3_bucket.logs.arn,
          aws_s3_bucket.replica_logs.arn

        ]

      },


      {

        Effect = "Allow"

        Action = [

          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication"

        ]

        Resource = [

          "${aws_s3_bucket.bucket.arn}/*",
          "${aws_s3_bucket.logs.arn}/*",
          "${aws_s3_bucket.replica_logs.arn}/*"

        ]

      },


      {

        Effect = "Allow"

        Action = [

          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"

        ]

        Resource = [

          "${aws_s3_bucket.replica.arn}/*",
          "${aws_s3_bucket.logs_replica.arn}/*",
          "${aws_s3_bucket.replica_logs_backup.arn}/*"

        ]

      },


      {

        Effect = "Allow"

        Action = [

          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"

        ]

        Resource = [

          aws_kms_key.s3.arn,
          aws_kms_key.s3_replica.arn

        ]

      }

    ]

  })

}



############################################
# REPLICATION CROSS REGION
############################################

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