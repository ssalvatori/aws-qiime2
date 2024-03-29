#
# Create S3 bucket
#

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.1"

  bucket = local.bucket_name


  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  force_destroy = true

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  server_side_encryption_configuration = {
    rule = { apply_server_side_encryption_by_default = {
      sse_algorithm = "AES256"
      }
    }
  }

}

resource "aws_iam_role" "this" {
  name = "qiime2-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_access" {
  name        = "EC2_ACCESS_S3"
  description = "Allow ec2 instance to use S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "MountpointFullBucketAccess"
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = module.s3.s3_bucket_arn
      },
      {
        Sid = "MountpointFullObjectAccess"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:GetObjectAttributes",
          "s3:GetObjectTagging"
        ]
        Effect   = "Allow"
        Resource = "${module.s3.s3_bucket_arn}/*"
      }
    ]
  })

  depends_on = [module.s3]
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "qiime2"
  role = aws_iam_role.this.name
}

