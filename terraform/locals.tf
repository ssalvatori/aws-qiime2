locals {
  private_key_filename = "${path.module}/id_qiime2"
  bucket_name          = var.bucket_name
}

data "aws_caller_identity" "current" {}
