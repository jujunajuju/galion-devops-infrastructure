#checkov:skip=CKV2_AWS_11:VPC Flow Logs are configured using aws_flow_log.vpc_flow_logs resource

resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  enable_dns_support = true

  enable_dns_hostnames = true


  tags = {

    Name = "${var.environment}-vpc"

  }

}


resource "aws_kms_key" "cloudwatch_logs" {

  description = "KMS key for VPC Flow Logs CloudWatch encryption"

  enable_key_rotation = true

}


resource "aws_cloudwatch_log_group" "vpc_flow_logs" {

  name = "/aws/vpc/${var.environment}/flowlogs"

  retention_in_days = 30

  kms_key_id = aws_kms_key.cloudwatch_logs.arn

}


resource "aws_iam_role" "vpc_flow_logs_role" {

  name = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]

  })

}


resource "aws_iam_role_policy" "vpc_flow_logs_policy" {

  name = "${var.environment}-vpc-flow-logs-policy"

  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]

        Resource = "*"
      }
    ]

  })

}


resource "aws_flow_log" "vpc_flow_logs" {

  vpc_id = aws_vpc.main.id

  traffic_type = "ALL"

  log_destination_type = "cloud-watch-logs"

  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

  iam_role_arn = aws_iam_role.vpc_flow_logs_role.arn

  depends_on = [
    aws_vpc.main,
    aws_cloudwatch_log_group.vpc_flow_logs,
    aws_iam_role.vpc_flow_logs_role
  ]

}


# Création du subnet public

resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet_cidr

  availability_zone = var.availability_zone


  map_public_ip_on_launch = true


  tags = {

    Name = "${var.environment}-public-subnet"

  }

}


# Internet Gateway

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id


  tags = {

    Name = "${var.environment}-igw"

  }

}


# Route Table publique

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id


  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }


  tags = {

    Name = "${var.environment}-public-route-table"

  }

}


# Association subnet avec route table

resource "aws_route_table_association" "public" {

  subnet_id = aws_subnet.public.id

  route_table_id = aws_route_table.public.id

}