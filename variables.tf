########################
# AWS
########################

variable "aws_region" {

  description = "Region AWS"

  type = string

  default = "us-east-1"

}



########################
# ENVIRONMENT
########################

variable "environment" {

  description = "Nom environnement"

  type = string

  default = "dev"

}



########################
# VPC
########################

variable "vpc_cidr" {

  description = "CIDR du VPC"

  type = string

  default = "10.0.0.0/16"

}



########################
# GCP
########################

variable "gcp_project" {

  description = "ID projet Google Cloud"

  type = string

  default = ""

}



variable "gcp_region" {

  description = "Region GCP"

  type = string

  default = "us-east-1"

}

########################
# PROJECT
########################

variable "project_name" {

  description = "Nom du projet"

  type = string

  default = "galion-devops"

}

########################
# EC2
########################

variable "instance_type" {

  description = "Type de l'instance EC2"

  type = string

  default = "t3.micro"

}

variable "key_pair_name" {

  description = "Nom de la Key Pair AWS"

  type = string

}