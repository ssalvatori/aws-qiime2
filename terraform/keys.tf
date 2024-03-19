resource "tls_private_key" "qiime2" {
  count = fileexists(local.private_key_filename) ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 2048


  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${trimspace(tls_private_key.qiime2[0].private_key_openssh)}' > ${local.private_key_filename}"
  }

  provisioner "local-exec" {
    command = "echo '${trimspace(tls_private_key.qiime2[0].public_key_openssh)}' > ${local.public_key_filename}"
  }

}

data "local_file" "public_ssh_key" {
  count = fileexists(local.public_key_filename) ? 1 : 0

  filename = local.public_key_filename

  depends_on = [tls_private_key.qiime2]
}

resource "aws_key_pair" "qiime2_key" {

  key_name = "qiime2-key"

  public_key = fileexists(local.public_key_filename) ? data.local_file.public_ssh_key[0].content : tls_private_key.qiime2[0].public_key_openssh

  depends_on = [tls_private_key.qiime2, data.local_file.public_ssh_key]
}

# resource "local_file" "pem_file" {
#   count = fileexists(local.private_key_filename) ? 0 : 1
#
#   filename        = pathexpand(local.private_key_filename)
#   file_permission = "600"
#   #  directory_permission = "700"
#   content = tls_private_key.qiime2[0].private_key_pem
# }

