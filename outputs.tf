output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "The arn for the S3 bucket"
}

output "dyanmodb_table_arn" {
    value = aws_dynamodb_table.terraform-locks.arn
    description = "The arn for the dynamodb table"
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_target_group_arn" {
  value = module.alb.alb_target_group_arn
}
