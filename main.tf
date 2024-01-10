# Variable Declaration
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
      default = "us-east-1"
}

# aws setup
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

# S3 bucket creation
resource "aws_s3_bucket" "my-static-website" {
  bucket = "mangalyaan"
  tags = {
    Name = "Mangalyaan"
  }
}

# S3 bucket Configuration
resource "aws_s3_bucket_website_configuration" "my-static-website"{
  bucket = aws_s3_bucket.my-static-website.id

  index_document {
    suffix = "about-mars.html"
  }
}


resource "aws_s3_bucket_versioning" "my-static-website"{
  bucket = aws_s3_bucket.my-static-website.id
  versioning_configuration {
    status = "Enabled"
  }
}


# S3 bucket ACL access
resource "aws_s3_bucket_ownership_controls" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id
  rule{
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "my-static-website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my-static-website,
    aws_s3_bucket_public_access_block.my-static-website,
  ]

  bucket = aws_s3_bucket.my-static-website.id
  acl = "public-read"
}

# Url of bucket
output "website_url" {
  value = "http://${aws_s3_bucket.my-static-website.bucket}.s3.${var.region}.amazonaws.com"
}
