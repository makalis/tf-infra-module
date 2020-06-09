terraform {
  backend "local" {}
}

locals {
  tf_state_s3_bucket      = "${ signum(length(var.tf_state_s3_bucket)) == 1 ? var.tf_state_s3_bucket : "${var.project}-${var.environment}-tf-state" }"
  tf_state_dynamodb_table = "${ signum(length(var.tf_state_dynamodb_table)) == 1 ? var.tf_state_dynamodb_table : "${var.project}-${var.environment}-tf-state" }"
}


resource "aws_s3_bucket" "terraform-state" {
  provider = aws.tfstate
  bucket   = local.tf_state_s3_bucket
  acl      = "private"

  tags = {
    Name        = "Terraform State Storage"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  provider       = aws.tfstate
  name           = local.tf_state_dynamodb_table
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Project     = var.project
    Environment = var.environment
  }
}