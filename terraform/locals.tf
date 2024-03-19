locals {
  private_key_filename = "${path.module}/id_qiime2"
  public_key_filename  = "${path.module}/id_qiime2.pub"

  bucket_name = var.bucket_name
}

data "aws_caller_identity" "current" {}
