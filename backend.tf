resource "aws_s3_bucket" "terraform_State" {
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