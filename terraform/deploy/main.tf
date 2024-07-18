# AWS provider and region

data "aws_caller_identity" "current" {
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region_primary
}
