# terraform{
#   backend "s3" {
#     bucket = "joekiff-dev-terrraform-bucket"
#     key =  "global/s3/terraform.tfstate"
#     region =  "eu-west-3"
#     dynamodb_table =  "terraform-locks"
#     encrypt = true
#   }
# }
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "joekiff-dev-terraform-bucket"
    acl = "private"
    
    force_destroy = true
    # enable versioning 
    versioning {
      enabled = true
    }
    # enable server side encryption  by default
    server_side_encryption_configuration {
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
    }
}

resource "aws_dynamodb_table" "terraform-locks" {
  name = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
      name = "LockID"
      type = "S"
  }
}