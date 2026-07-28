module "aws_vpc" {
  source = "./modules/aws/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  aws_region  = var.aws_region
}

module "ec2" {

  source = "./modules/aws/ec2"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.aws_vpc.vpc_id

  subnet_id = module.aws_vpc.public_subnet_id

  instance_type = var.instance_type

  key_name = var.key_pair_name
}

module "s3" {

  source = "./modules/aws/s3"

  providers = {
    aws.replication = aws.replication
  }

  project_name = var.project_name

  environment = var.environment

}