resource "aws_s3_bucket" "terraform_state" {

  bucket = "${var.project_name}-terraform-state"

  tags = {
    Name        = "${var.project_name}-terraform-state"
    Environment = var.environment
  }

}