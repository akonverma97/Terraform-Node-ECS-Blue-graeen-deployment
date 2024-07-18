########################
# General stacks       # 
########################

variable "stack" {
  type        = string
  description = "Enter the stack name Eg: AI, Node"
}

variable "environment" {
  type        = string
  description = "Enter the environment name"
}

variable "account_id" {
  type        = string
  description = "Enter the AWS account ID"
}

variable "region_primary" {
  type        = string
  description = "Primary AWS region for this account"
}