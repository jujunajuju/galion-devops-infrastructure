resource "aws_security_group" "ec2" {

  name = "${var.project_name}-${var.environment}-sg"

  description = "Security group for EC2 instance"

  vpc_id = var.vpc_id


  ingress {

    description = "SSH access"

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {

    description = "HTTP access"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  egress {

    description = "Allow outbound traffic"

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {

    Name = "${var.project_name}-${var.environment}-sg"

  }

}