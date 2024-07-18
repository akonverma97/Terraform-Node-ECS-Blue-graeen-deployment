#####################################
#  CodePipeline role and policy     #
#####################################

resource "aws_iam_policy" "backendcodepipeline" {
  name        = "${var.stack}-${var.environment}-${var.workspace_backend}-codepipeline-policy"
  description = "${var.stack}-${var.environment}-${var.workspace_backend}-codepipeline-policy"
  policy      = data.aws_iam_policy_document.codepipeline_policy.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"

      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "VisualEditor1"
    effect = "Allow"

    resources = [
      "arn:aws:kms:*:*:key/*",
      "arn:aws:logs:*:*:log-group:*",
    ]

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:RevokeGrant",
      "logs:*",
      "kms:GenerateDataKey",
      "kms:ReEncryptTo",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ReEncryptFrom",
      "kms:ListGrants",
    ]
  }

  statement {
    sid       = "VisualEditor2"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:GetLogRecord",
      "opsworks:DescribeStacks",
      "devicefarm:GetRun",
      "cloudformation:CreateChangeSet",
      "autoscaling:*",
      "logs:ListLogDeliveries",
      "codebuild:BatchGetBuilds",
      "servicecatalog:ListProvisioningArtifacts",
      "devicefarm:ScheduleRun",
      "devicefarm:ListDevicePools",
      "logs:CancelExportTask",
      "cloudformation:UpdateStack",
      "servicecatalog:DescribeProvisioningArtifact",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "devicefarm:ListProjects",
      "logs:DescribeDestinations",
      "sns:*",
      "lambda:ListFunctions",
      "codedeploy:RegisterApplicationRevision",
      "lambda:InvokeFunction",
      "cloudformation:*",
      "opsworks:DescribeDeployments",
      "devicefarm:CreateUpload",
      "logs:StopQuery",
      "logs:CreateLogGroup",
      "cloudformation:DescribeStacks",
      "logs:CreateLogDelivery",
      "codecommit:GetUploadArchiveStatus",
      "logs:PutResourcePolicy",
      "logs:DescribeExportTasks",
      "logs:GetQueryResults",
      "cloudwatch:*",
      "logs:UpdateLogDelivery",
      "cloudformation:DeleteStack",
      "opsworks:DescribeInstances",
      "ecr:DescribeImages",
      "ecs:*",
      "ec2:*",
      "codebuild:StartBuild",
      "cloudformation:ValidateTemplate",
      "opsworks:DescribeApps",
      "opsworks:UpdateStack",
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeploymentConfig",
      "servicecatalog:CreateProvisioningArtifact",
      "sqs:*",
      "logs:GetLogDelivery",
      "cloudformation:DeleteChangeSet",
      "codecommit:GetCommit",
      "logs:DeleteResourcePolicy",
      "servicecatalog:DeleteProvisioningArtifact",
      "logs:DeleteLogDelivery",
      "logs:PutDestination",
      "logs:DescribeResourcePolicies",
      "codedeploy:GetApplication",
      "logs:DescribeQueries",
      "cloudformation:SetStackPolicy",
      "codecommit:UploadArchive",
      "s3:*",
      "logs:PutDestinationPolicy",
      "elasticloadbalancing:*",
      "logs:TestMetricFilter",
      "logs:DeleteDestination",
      "codecommit:CancelUploadArchive",
      "devicefarm:GetUpload",
      "elasticbeanstalk:*",
      "opsworks:UpdateApp",
      "opsworks:CreateDeployment",
      "cloudformation:CreateStack",
      "servicecatalog:UpdateProduct",
      "codecommit:GetBranch",
      "codedeploy:GetDeployment",
      "opsworks:DescribeCommands",
      "cloudfront:*",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codestar-connections:${var.region_primary}:${var.account_id}:connection/*"]
    actions   = ["codestar-connections:UseConnection"]
  }
}

resource "aws_iam_role" "backendcodepipeline" {
  name        = "${var.stack}-${var.environment}-${var.workspace_backend}-codepipeline"
  description = "${var.stack}-${var.environment}-${var.workspace_backend}-codepipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  	  "Action": "sts:AssumeRole",
  	  "Principal": {
  		"Service": "codepipeline.amazonaws.com"
  	  },
  	  "Effect": "Allow",
  	  "Sid": ""
  	}
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "backendcodepipeline" {
  name       = aws_iam_policy.backendcodepipeline.name
  roles      = [aws_iam_role.backendcodepipeline.name]
  policy_arn = aws_iam_policy.backendcodepipeline.arn
}

#################################
# CodeBuild role and policy     #
#################################

resource "aws_iam_policy" "backendcodebuild" {
  name        = "${var.stack}-${var.environment}-${var.workspace_backend}-codebuild-policy"
  description = "${var.stack}-${var.environment}-${var.workspace_backend}-codebuild-policy"
  policy      = data.aws_iam_policy_document.codebuild_policy.json
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:logs:${var.region_primary}:${var.account_id}:log-group:/aws/codebuild/${var.stack}-${var.environment}-${var.workspace_backend}",
      "arn:aws:logs:${var.region_primary}:${var.account_id}:log-group:/aws/codebuild/${var.stack}-${var.environment}-${var.workspace_backend}:*",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::codepipeline-${var.region_primary}-*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codebuild:${var.region_primary}:${var.account_id}:report-group/${var.stack}-${var.environment}-*"]

    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:*",
      "cloudtrail:LookupEvents",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["replication.ecr.amazonaws.com"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:ec2:${var.region_primary}:${var.account_id}:network-interface/*"]
    actions   = ["ec2:CreateNetworkInterfacePermission"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values   = ["arn:aws:ec2:${var.region_primary}:${var.account_id}:subnet/[[subnets]]"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    sid       = "CodeBuild"
    effect    = "Allow"
    resources = ["arn:aws:codebuild:${var.region_primary}:${var.account_id}:report-group/${var.stack}-${var.environment}-*"]

    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
    ]
  }

  statement {
    sid       = "SecretsManager"
    effect    = "Allow"
    resources = ["arn:aws:secretsmanager:${var.region_primary}:${var.account_id}:secret:${var.stack}-${var.environment}*"]

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
  }

  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    resources = ["arn:aws:ec2:${var.region_primary}:${var.account_id}:network-interface/*"]
    actions   = ["ec2:CreateNetworkInterfacePermission"]

    condition {
      test     = "StringLike"
      variable = "ec2:Subnet"
      values   = ["arn:aws:ec2:${var.region_primary}:${var.account_id}:subnet/*"]
    }

    condition {
      test     = "StringLike"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    sid       = "kmsaccess"
    effect    = "Allow"
    resources = [var.kms_key_arn]

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:RevokeGrant",
      "kms:ReEncryptTo",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ReEncryptFrom",
      "kms:ListGrants",
    ]
  }

  statement {
    sid    = "S3"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.stack}-${var.environment}-codepipeline-artifact/*",
      "arn:aws:s3:::${var.stack}-${var.environment}-codepipeline-artifact",
      "arn:aws:s3:::*",
    ]

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:*",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetDistribution",
    ]
  }
}

resource "aws_iam_role" "backendcodebuild" {
  name        = "${var.stack}-${var.environment}-${var.workspace_backend}-codebuild"
  description = "${var.stack}-${var.environment}-${var.workspace_backend}-codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  	  "Action": "sts:AssumeRole",
  	  "Principal": {
  		"Service": "codebuild.amazonaws.com"
  	  },
  	  "Effect": "Allow",
  	  "Sid": ""
  	}
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "backendcodebuild" {
  name       = aws_iam_policy.backendcodebuild.name
  roles      = [aws_iam_role.backendcodebuild.name]
  policy_arn = aws_iam_policy.backendcodebuild.arn
}


###################################
# CodeDeploy role and policies    #
###################################

resource "aws_iam_policy" "backendcodedeploy" {
  name        = "${var.stack}-${var.environment}-${var.workspace_backend}-codedeploy-policy"
  description = "${var.stack}-${var.environment}-${var.workspace_backend}-codedeploy-policy"
  policy      = data.aws_iam_policy_document.codedeploy_policy.json
}

resource "aws_iam_role" "backendcodedeploy" {
  name               = "${var.stack}-${var.environment}-${var.workspace_backend}-codedeploy"
  description        = "${var.stack}-${var.environment}-${var.workspace_backend}-codedeploy"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "backendcodedeploy" {
  name       = aws_iam_policy.backendcodedeploy.name
  roles      = [aws_iam_role.backendcodedeploy.name]
  policy_arn = aws_iam_policy.backendcodedeploy.arn
}

data "aws_iam_policy_document" "codedeploy_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecs:DescribeServices",
      "ecs:CreateTaskSet",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:DeleteTaskSet",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:ModifyRule",
      "lambda:InvokeFunction",
      "cloudwatch:DescribeAlarms",
      "sns:Publish",
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"

      values = [
        "ecs-tasks.amazonaws.com",
        "ec2.amazonaws.com",
      ]
    }
  }
}