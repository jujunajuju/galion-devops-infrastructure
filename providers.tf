terraform {
  required_version = ">= 1.6.0"

  #backend "s3" {
  #  bucket = "galion-devops-terraform-state"
  #  key    = "terraform.tfstate"
  #  region = "us-east-1"
  #}

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}


# Provider AWS principal
provider "aws" {
  region = var.aws_region
}


# Provider AWS pour réplication S3
provider "aws" {
  alias  = "replication"
  region = "eu-west-1"
}


# Provider Azure
provider "azurerm" {
  features {}
}


# Provider GCP
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}