#
# 

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "qiime2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  subnet_id = aws_subnet.main.id

  availability_zone = data.aws_availability_zones.main.names[0]

  iam_instance_profile = aws_iam_instance_profile.this.id

  associate_public_ip_address = true

  key_name = aws_key_pair.qiime2_key.key_name

  vpc_security_group_ids = [aws_security_group.main.id]
  user_data              = file("setup.sh")

  ebs_optimized = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "qiime2"
  }


  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  depends_on = [aws_internet_gateway.main]

}

output "ec2-instance-ip" {
  value = aws_instance.qiime2.public_ip
}
