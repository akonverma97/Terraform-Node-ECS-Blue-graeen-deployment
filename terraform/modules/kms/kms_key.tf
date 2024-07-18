####################
# KMS Key          #
####################

resource "aws_kms_key" "encryption_key" {
  description         = "KMS key for RDS, EBS, and S3 encryption"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "KMSPolicy",
    Statement = [
      {
        Sid    = "Enable Full Access for Account",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid       = "AllowRDSAndEBSToUseKey",
        Effect    = "Allow",
        Principal = { Service = ["rds.amazonaws.com", "ec2.amazonaws.com"] },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "kms:ViaService" : "rds.${var.region_primary}.amazonaws.com",
            "kms:ViaService" : "ec2.${var.region_primary}.amazonaws.com"
          }
        }
      },
      {
        Sid       = "AllowS3ToUseKey",
        Effect    = "Allow",
        Principal = { Service = "s3.amazonaws.com" },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "kms:ViaService" : "s3.${var.region_primary}.amazonaws.com"
          }
        }
      },
      {
        Sid       = "AllowCodePipelineToUseKey",
        Effect    = "Allow",
        Principal = { Service = "codepipeline.amazonaws.com" },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "kms:ViaService" : "codepipeline.${var.region_primary}.amazonaws.com"
          }
        }
      },
      {
        Sid       = "AllowCodeBuildToUseKey",
        Effect    = "Allow",
        Principal = { Service = "codebuild.amazonaws.com" },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "kms:ViaService" : "codebuild.${var.region_primary}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.stack}-${var.environment}-encryption-key"
  }
}

resource "aws_kms_alias" "encryption_key_alias" {
  name          = "alias/${var.stack}-${var.environment}-encryption-keyalias"
  target_key_id = aws_kms_key.encryption_key.key_id
}

