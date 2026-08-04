#############################################
# KMS KEY REPLICA EU-WEST-1
#############################################

resource "aws_kms_key" "terraform_state_replica" {

  provider = aws.replication

  description = "KMS key for Terraform state replica encryption"

  enable_key_rotation = true


  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "Enable IAM User Permissions"

        Effect = "Allow"

        Principal = {

          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

        }

        Action = "kms:*"

        Resource = "*"

      }

    ]

  })


  tags = {

    Name = "${var.project_name}-terraform-state-replica-kms"

    Environment = var.environment

  }

}



#############################################
# BUCKET REPLICA
#############################################

resource "aws_s3_bucket" "terraform_state_replica" {

  provider = aws.replication


  bucket = "${var.project_name}-terraform-state-replica"


  tags = {

    Name = "${var.project_name}-terraform-state-replica"

    Environment = var.environment

  }

}



#############################################
# PUBLIC ACCESS BLOCK REPLICA
#############################################

resource "aws_s3_bucket_public_access_block" "terraform_state_replica_public_access_block" {

  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica.id


  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true

}



#############################################
# ENCRYPTION REPLICA
#############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_replica_encryption" {


  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica.id



  rule {


    apply_server_side_encryption_by_default {


      sse_algorithm = "aws:kms"


      kms_master_key_id = aws_kms_key.terraform_state_replica.arn

    }


    bucket_key_enabled = true

  }

}



#############################################
# VERSIONING REPLICA
#############################################

resource "aws_s3_bucket_versioning" "terraform_state_replica_versioning" {


  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica.id



  versioning_configuration {

    status = "Enabled"

  }

}



#############################################
# LIFECYCLE REPLICA
#############################################

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_replica_lifecycle" {


  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica.id



  rule {


    id = "cleanup-old-replica"

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





#############################################
# BUCKET LOGS REPLICA
#############################################

resource "aws_s3_bucket" "terraform_state_replica_logs" {


  provider = aws.replication


  bucket = "${var.project_name}-terraform-state-replica-logs"



  tags = {

    Name = "${var.project_name}-terraform-state-replica-logs"

    Environment = var.environment

  }

}



#############################################
# PUBLIC ACCESS LOGS REPLICA
#############################################

resource "aws_s3_bucket_public_access_block" "terraform_state_replica_logs_public_access_block" {


  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica_logs.id



  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true

}



#############################################
# KMS LOGS REPLICA
#############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_replica_logs_encryption" {


  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica_logs.id



  rule {


    apply_server_side_encryption_by_default {


      sse_algorithm = "aws:kms"


      kms_master_key_id = aws_kms_key.terraform_state_replica.arn

    }


    bucket_key_enabled = true

  }

}





#############################################
# VERSIONING LOGS REPLICA
#############################################

resource "aws_s3_bucket_versioning" "terraform_state_replica_logs_versioning" {


  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica_logs.id



  versioning_configuration {


    status = "Enabled"


  }

}





#############################################
# LIFECYCLE LOGS REPLICA
#############################################

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_replica_logs_lifecycle" {


  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica_logs.id



  rule {


    id = "cleanup-old-logs"

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





#############################################
# LOGGING REPLICA
#############################################

resource "aws_s3_bucket_logging" "terraform_state_replica_logging" {


  provider = aws.replication


  bucket = aws_s3_bucket.terraform_state_replica.id


  target_bucket = aws_s3_bucket.terraform_state_replica_logs.id


  target_prefix = "logs/"

}





#############################################
# IAM ROLE REPLICATION
#############################################

resource "aws_iam_role" "terraform_state_replication_role" {


  name = "${var.project_name}-terraform-state-replication-role"



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





#############################################
# IAM POLICY REPLICATION
#############################################

resource "aws_iam_role_policy" "terraform_state_replication_policy" {


  name = "${var.project_name}-terraform-state-replication-policy"


  role = aws_iam_role.terraform_state_replication_role.id



  policy = jsonencode({


    Version = "2012-10-17"


    Statement = [


      {


        Effect = "Allow"


        Action = [

          "s3:GetReplicationConfiguration",

          "s3:ListBucket"

        ]


        Resource = aws_s3_bucket.terraform_state.arn

      },



      {


        Effect = "Allow"


        Action = [

          "s3:GetObjectVersionForReplication",

          "s3:GetObjectVersionAcl",

          "s3:GetObjectVersionTagging"

        ]


        Resource = "${aws_s3_bucket.terraform_state.arn}/*"

      },



      {


        Effect = "Allow"


        Action = [

          "s3:ReplicateObject",

          "s3:ReplicateDelete",

          "s3:ReplicateTags"

        ]


        Resource = "${aws_s3_bucket.terraform_state_replica.arn}/*"

      },



      {


        Effect = "Allow"


        Action = [

          "kms:Encrypt",

          "kms:Decrypt",

          "kms:ReEncrypt*",

          "kms:GenerateDataKey",

          "kms:DescribeKey"

        ]


        Resource = aws_kms_key.terraform_state_replica.arn

      }


    ]

  })

}





#############################################
# REPLICATION STATE -> REPLICA
#############################################

resource "aws_s3_bucket_replication_configuration" "terraform_state_replication" {


  role = aws_iam_role.terraform_state_replication_role.arn


  bucket = aws_s3_bucket.terraform_state.id



  rule {


    id = "terraform-state-replication"


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


      bucket = aws_s3_bucket.terraform_state_replica.arn


      account = data.aws_caller_identity.current.account_id


      storage_class = "STANDARD"



      encryption_configuration {


        replica_kms_key_id = aws_kms_key.terraform_state_replica.arn

      }

    }

  }

}





#############################################
# REPLICATION LOGS -> LOGS REPLICA
#############################################

resource "aws_s3_bucket_replication_configuration" "terraform_state_logs_replication" {


  role = aws_iam_role.terraform_state_replication_role.arn


  bucket = aws_s3_bucket.terraform_state_logs.id

  depends_on = [
    aws_s3_bucket_versioning.terraform_state_logs_versioning,
    aws_s3_bucket_versioning.terraform_state_replica_logs_versioning
]



  rule {


    id = "terraform-state-logs-replication"


    status = "Enabled"



    filter {}



    delete_marker_replication {


      status = "Enabled"

    }



    destination {


      bucket = aws_s3_bucket.terraform_state_replica_logs.arn


      account = data.aws_caller_identity.current.account_id


      storage_class = "STANDARD"


    }

  }

}