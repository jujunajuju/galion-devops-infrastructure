resource "aws_instance" "ec2" {

  ami           = "ami-0c7217cdde317cfec"
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2"
  }

}