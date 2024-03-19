terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.41.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.aws_default_tags
  }
}
