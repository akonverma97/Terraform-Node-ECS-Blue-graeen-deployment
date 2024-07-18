variable "environment" {
  description = "App environment"
  default = "stage"
}

variable "application" {
  type        = list(string)
  description = "Enter the application name like node, laravel, wordpress, etc"
  default = [ "node" ]
}

variable "region_primary" {
  type        = string
  description = "Primary AWS region for this account"
  default = "ap-south-1"
}

variable "access_key" {
  type        = string
  description = "Primary AWS access_key for this account"
  default = "add here access key "
}

variable "secret_key" {
  type        = string
  description = "Primary AWS secret_key for this account"
  default = "add here secret key "
}

#Stack Tags
variable "stack" {
  type        = string
  description = "Defines the application stack to which this component is related. (e.g AirView, PivotalCloud, Exchange)"
  default = "node"
}

variable "workspace_backend" {
  type        = string
  description = "Enter the name of workspace Eg: Backend, UI"
  default = "backend"
}

variable "account_id" {
  type        = string
  description = "Enter the AWS account ID"
}



# ##################
# # ALB variables  #
# ##################

variable "health_check_path" {
  type        = string
  description = "Enter the health check path for the Loadbalancer target group"
  default     = "/"
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# ############################
# # Networking variables     #
# ############################

variable "vpc_id" {
  type        = string
  description = "Enter the ID of VPC Network"
  default = "vpc-06c5513004f60020a"
}

variable "pub_subnet_ids" {
  type        = list(string)
  description = "Enter the list of Public subnet Ids"
  default = [ "subnet-05e17889e3185278e", "subnet-0e7ba399f59cd0d87", "subnet-0c4783f4b86dc3ceb" ]
}

variable "pri_subnet_ids" {
  type = list(string)
  default = [ "subnet-0b531e821d569e4f3", "subnet-0e36cced40d82763a", "subnet-0a2c7210f9714035b" ]
}

# #########################
# # ECS Variables         #
# #########################

variable "container_port" {
  type        = number
  description = "Enter the port number to be set for the container"
  default = 80
}

variable "memory" {
  type        = number
  description = "Enter the memory value to be set for the container"
  default = 512
}

# EC2 variables
variable "ecs_instance_type" {
  type        = string
  description = "Enter the type of the EC2 instance to be launched"
  default = "t3.small"
}

# ######################
# # Codepipeline vars  #
# ######################

variable "source_codeprefix" {
  type        = string
  description = "Enter the codeprefix of the source code Eg: # username/reponame/branchname/username_reponame.zip"
  default = "karthikeya2024/nodejs/master/karthikeya2024_nodejs.zip"
}

variable "sourcecode_bucket" {
  type        = string
  description = "Enter the source code bucket name"
  default = "node-dev-backend-source-code"
}

variable "build_timeout" {
  description = "CodeBuild build timeout in minutes"
  default     = "10"
}

variable "buildspec_path" {
  type        = string
  description = "Enter the path of the buildspec file"
  default = "buildspec.yml"
}


############
# KMS Key  #
############

variable "kms_key_arn" {
  type        = string
  description = "Enter the KMS key arn"
  default = "arn:aws:kms:us-west-2:891377317236:key/888ea803-516d-42f1-9b0d-b3edf6cad903"
}

# variable "lambda_codebuild_sg" {
#   type        = string
#   description = "Enter the codebuild security group ID"
# }
