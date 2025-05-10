provider "aws" {
  region = "us-east-2"
}

#terraform {
#  backend "s3" {
#    key = "global/s3/terraform.tfstate"
#  }
#}

resource "aws_s3_bucket" "terraform-test1" {
  bucket = "estudos-terraform-test1"

  #lifecycle {
   # prevent_destroy = true
  #}
}

#Enable versioning so you can see the full revision history of your states files
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform-test1.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform-test1.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform-test1.id

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}

resource "aws_dynamodb_table" "terraform-locks" {
  name = "terraform-states-files"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}