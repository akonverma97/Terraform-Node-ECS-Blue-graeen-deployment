###################################
# Gitpull Module for Backend      #
###################################

module "backend_gitpull" {
  source      = "../modules/gitpull_template"
  stack       = var.stack
  environment = var.environment
  workspace   = "backend"
}

###################################
# Gitpull Module for vpc          #
###################################


module "vpc" {
  source              = "../modules/vpc"
  stack               = var.stack
  region_primary      = var.region_primary
}

# ##################
# # KMS Key        #
# ##################

module "kms_key" {
  source         = "../modules/kms"
  stack          = var.stack
  environment    = var.environment
  region_primary = var.region_primary
  account_id     = data.aws_caller_identity.current.account_id
}

# #######################
# # ECS B/G deployment  #
# #######################
# module "ecs_backend" {
#   source               = "../modules/ecs_backend"
#   stack                = var.stack
#   environment          = var.environment
#   region_primary       = var.region_primary
#   account_id           = var.account_id
#   vpc_id               = var.vpc_id
#   pub_subnet_ids       = var.pub_subnet_ids
#   pri_subnet_ids       = var.pri_subnet_ids
#   memory               = var.memory
#   container_port       = var.container_port
#   ecs_instance_type    = "t3.small"
#   buildspec_path       = var.buildspec_path
#   source_codeprefix    = var.source_codeprefix
#   workspace_backend    = var.workspace_backend
#   sourcecode_bucket    = var.sourcecode_bucket
#   kms_key_arn          = var.kms_key_arn
# } 