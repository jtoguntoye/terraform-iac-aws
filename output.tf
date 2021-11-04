output "alb_dns_name" {
    value = aws_lb.ext-alb.dns_name
}

output "alb_target_group_arn" {
    value = aws_lb_target_group.nginx-tgt.arn
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_State.arn
    description = "The arn for the S3 bucket"
}

output "dyanmodb_table_arn" {
    value = aws_dynamodb_table.terraform-locks.arn
    description = "The arn for the dynamodb table"
}