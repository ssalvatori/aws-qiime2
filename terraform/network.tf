
data "aws_availability_zones" "main" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "qiime2-main"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = data.aws_availability_zones.main.names[0]

  tags = {
    Name = "qiime2-private"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "qiime2-gw"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

data "http" "ip" {
  #url = "https://ifconfig.me/ip"
  url = "http://ipinfo.io/ip"
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.qiime2-main.id
}

resource "aws_route_table" "qiime2-main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rt-qiime2"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

}

resource "aws_route_table_association" "rt-internet" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.qiime2-main.id
}


resource "aws_security_group" "main" {
  name        = "ssh-qiime2"
  description = "Allow SSH to qiime2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH ingress from local ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip.response_body)}/32"]
  }

  ingress {
    description = "SSH ingress from anywere (aws console)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}


resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = {
    Name = "qiime2-s3"
  }


  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = aws_route_table.qiime2-main.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}
