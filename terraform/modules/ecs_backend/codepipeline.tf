
################
# Codepipeline #
################

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.stack}-${var.environment}-codepipeline-artifact"
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_bucket_lifecycle" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.codepipeline_bucket]
  bucket     = aws_s3_bucket.codepipeline_bucket.id

  rule {
    id = "delete old artifacts"
    noncurrent_version_expiration {
      noncurrent_days = 45
    }
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
    status = "Enabled"
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.stack}-${var.environment}-${var.workspace_backend}"
  role_arn = aws_iam_role.backendcodepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        S3Bucket    = var.sourcecode_bucket
        S3ObjectKey = var.source_codeprefix # username/reponame/branchname/username_reponame.zip
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["DefinitionArtifact", "ImageArtifact"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      namespace       = "DeployVariables"
      name            = "ExternalDeploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["DefinitionArtifact", "ImageArtifact"]
      version         = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.this.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.this.deployment_group_name
        TaskDefinitionTemplateArtifact = "DefinitionArtifact"
        Image1ArtifactName             = "ImageArtifact"
        Image1ContainerName            = "IMAGE_NAME"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "DefinitionArtifact"
        AppSpecTemplatePath            = "appspec.yaml"
      }
    }
  }

}
