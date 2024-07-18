##################
# Code Build     #
##################

resource "aws_codebuild_project" "codebuild" {
  name          = "${var.stack}-${var.environment}-${var.workspace_backend}"
  description   = "${var.stack}-${var.environment}-${var.workspace_backend}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.backendcodebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }
  cache {
    type = "NO_CACHE"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_path
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "APP_PORT"
      value = var.container_port
    }
    environment_variable {
      name  = "NODEENV"
      value = var.environment
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region_primary
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }
    environment_variable {
      name  = "ECR_REPO_APP"
      value = aws_ecr_repository.ecr.name
    }
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "/${var.stack}/${var.environment}/${var.workspace_backend}/codebuild"
      stream_name = "codebuild"
    }
    s3_logs {
      status = "DISABLED"
    }
  }

}