variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "jira-project-state"
}

variable "s3_versioning_configuration" {
  description = "Whether the S3 bucket versioning should be enabled"
  type        = string
  default     = "Enabled"
}

variable "s3_logging_target_prefix" {
  description = "The target prefix/path of the logs"
  type        = string
  default     = "log/"
}

variable "s3_encryption_sse_algorithm" {
  description = "The sse algorithm used for server side encryption"
  type        = string
  default     = "aws:kms"
}

variable "s3_block_public_acl" {
  description = "Whether public acls should be blocked"
  type        = bool
  default     = true
}

variable "s3_block_public_policy" {
  description = "Whether public policies should be blocked"
  type        = bool
  default     = true
}

variable "s3_ignore_public_acls" {
  description = "Whether public policies should be ignored"
  type        = bool
  default     = true
}

variable "s3_restrict_public_buckets" {
  description = "Whether public policies should be blocked"
  type        = bool
  default     = true
}

variable "kms_key_enabled" {
  description = "KMS key is_enabled parameter"
  type        = bool
  default     = true
}

variable "kms_key_rotation" {
  description = "KMS key rotation parameter"
  type        = bool
  default     = true
}

variable "kms_key_deletion_period" {
  description = "The deletion window in days for the kms key"
  type        = number
  default     = 7
}

variable "dynamodb_table_name" {
  description = "The name of the dynamodb table"
  type        = string
  default     = "terraform-state-locking"
}

variable "dynamodb_table_billing_mode" {
  description = "The billing mode of the dynamodb table"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_table_hash_key" {
  description = "The hash key for the dynamodb table"
  type        = string
  default     = "LockID"
}

variable "dynamodb_table_recovery" {
  description = "Whether the dynamodb table has point in time recovery enabled"
  type        = bool
  default     = true
}

variable "dynamodb_table_encryption" {
  description = "Whether the dynamodb table has server side encryption"
  type        = bool
  default     = true
}

variable "dynamodb_table_lockId_type" {
  description = "The type of the LockID"
  type        = string
  default     = "S"
}
