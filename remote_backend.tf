data "aws_s3_bucket" "existing_bucket" {
  bucket =  "my-s3-bucket231" 
}
resource "aws_s3_bucket" "terraform_state" {
  count  = length(data.aws_s3_bucket.existing_bucket.id) == 0 ? 1 : 0
  bucket = "my-s3-bucket231"  
  force_destroy = true
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "Terraform State Bucket"
  }
}
resource "aws_s3_bucket_versioning" "enable" {
  count = length(data.aws_s3_bucket.existing_bucket.id) == 0 ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "dynamodb-locks"  
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    ignore_changes = [name]
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
 
terraform {
  backend "s3" {
    bucket         =  "my-s3-bucket231"   
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "NM-locks"
    encrypt        = true
  }
}
