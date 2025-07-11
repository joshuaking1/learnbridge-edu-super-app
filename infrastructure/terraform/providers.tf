# Specifies the required provider (AWS) and its version.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the AWS provider, using the region defined in our environment variables.
provider "aws" {
  region = var.aws_region
}