terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">5.0, <6.0" # Or the latest version you want to use
    }
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile # Use the defined profile
}


