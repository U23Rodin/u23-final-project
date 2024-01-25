# Define a resource for an S3 bucket to store Terraform state.
resource "aws_s3_bucket" "terraform_state" {
  # Bucket name, defined as a variable for flexibility.
  bucket = var.s3_bucket_name

  # Lifecycle rule to prevent accidental destruction of the bucket.
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for the S3 bucket to keep a history of changes and enable rollback if needed.
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = var.s3_versioning_configuration
  }
}

# Configure logging for the S3 bucket to track access and usage for security and auditing purposes.
resource "aws_s3_bucket_logging" "terraform_state" {
  # Specify the bucket to apply logging settings to.
  bucket = aws_s3_bucket.terraform_state.id

  # Store log files in the same bucket with a defined prefix.
  target_bucket = aws_s3_bucket.terraform_state.id
  target_prefix = var.s3_logging_target_prefix
}

# Server-side encryption configuration for the S3 bucket to enhance data security.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket

  # Define the encryption rule using the KMS key.
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = var.s3_encryption_sse_algorithm
    }
  }
}

# Public access block settings for the S3 bucket to prevent public access and enhance security.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  # Variables control the public access settings.
  block_public_acls       = var.s3_block_public_acl
  block_public_policy     = var.s3_block_public_policy
  ignore_public_acls      = var.s3_ignore_public_acls
  restrict_public_buckets = var.s3_restrict_public_buckets
}

# Create a KMS key for encryption of the S3 bucket and DynamoDB table.
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for DynamoDB table and S3 bucket encryption"
  is_enabled              = var.kms_key_enabled
  enable_key_rotation     = var.kms_key_rotation
  deletion_window_in_days = var.kms_key_deletion_period
}

# Define a DynamoDB table for Terraform state locking.
resource "aws_dynamodb_table" "terraform_locks" {
  # Table configuration variables for flexibility.
  name         = var.dynamodb_table_name
  billing_mode = var.dynamodb_table_billing_mode
  hash_key     = var.dynamodb_table_hash_key

  point_in_time_recovery {
    enabled = var.dynamodb_table_recovery
  }

  server_side_encryption {
    enabled     = var.dynamodb_table_encryption
    kms_key_arn = aws_kms_key.terraform_state.arn
  }

  attribute {
    name = var.dynamodb_table_hash_key
    type = var.dynamodb_table_lockId_type
  }
}
