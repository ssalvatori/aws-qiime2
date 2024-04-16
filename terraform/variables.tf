
variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_default_tags" {
  type = map(string)
  default = {
    Environment = "Development"
    Name        = "qiime2"
    Terraform   = "true"
  }
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type    = string
  default = "10.0.100.0/24"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "m7i.xlarge"
}

variable "ec2_volume_size" {
  description = "EC2 volume size"
  default     = 30
  type        = number
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket to be used to store files"
  default     = "qiime2-ec2-test"
}

variable "create_bucket" {
  type        = bool
  description = "Create S3 bucket"
  default     = false
}
