terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.41.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
  required_version = "1.5.7"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.aws_default_tags
  }
}
