
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

variable "workspace_backend" {
  type        = string
  description = "Enter the name of workspace Eg: Backend, UI"
}

variable "region_primary" {
  type        = string
  description = "Primary AWS region for this account"
}

variable "account_id" {
  type        = string
  description = "Enter the AWS account ID"
}

##################
# ALB variables  #
##################

variable "health_check_path" {
  type        = string
  description = "Enter the health check path for the Loadbalancer target group"
  default     = "/"
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

############################
# Networking variables     #
############################

variable "vpc_id" {
  type        = string
  description = "Enter the ID of VPC Network"
}

variable "pub_subnet_ids" {
  type        = list(string)
  description = "Enter the list of Public subnet Ids"
}

variable "pri_subnet_ids" {
  type = list(string)
}

#########################
# ECS Variables         #
#########################

variable "container_port" {
  type        = number
  description = "Enter the port number to be set for the container"
}

variable "memory" {
  type        = number
  description = "Enter the memory value to be set for the container"
}

# EC2 variables
variable "ecs_instance_type" {
  type        = string
  description = "Enter the type of the EC2 instance to be launched"
}

######################
# Codepipeline vars  #
######################

variable "source_codeprefix" {
  type        = string
  description = "Enter the codeprefix of the source code Eg: # username/reponame/branchname/username_reponame.zip"
}

variable "sourcecode_bucket" {
  type        = string
  description = "Enter the source code bucket name"
}

variable "build_timeout" {
  description = "CodeBuild build timeout in minutes"
  default     = "10"
}
# variable "sns_arn" {
#   description = "Enter the email Id for the Pipeline alerts"
#   type        = string
# }

variable "buildspec_path" {
  type        = string
  description = "Enter the path of the buildspec file"
}


############
# KMS Key  #
############

variable "kms_key_arn" {
  type        = string
  description = "Enter the KMS key arn"
}

# variable "lambda_codebuild_sg" {
#   type        = string
#   description = "Enter the codebuild security group ID"
# }