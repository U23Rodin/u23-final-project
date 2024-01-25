# Output for S3 Bucket Name
output "s3_bucket_name" {
  description = "The name of the S3 bucket used for Terraform state storage"
  value       = aws_s3_bucket.terraform_state.bucket
}

# Output for DynamoDB Table Name
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

