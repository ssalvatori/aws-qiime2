resource "tls_private_key" "qiime2" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "private_file" {
  filename             = pathexpand(local.private_key_filename)
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.qiime2.private_key_openssh
}

resource "aws_key_pair" "qiime2_key" {

  key_name   = "qiime2-key"
  public_key = tls_private_key.qiime2.public_key_openssh

  depends_on = [
    tls_private_key.qiime2,
  ]
}