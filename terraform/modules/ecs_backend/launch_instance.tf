data "aws_ami" "latest_ecs" {
  most_recent = true
  owners      = ["amazon"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "launch_template" {
  name          = "${var.stack}-${var.environment}-${var.workspace_backend}"
  image_id      = data.aws_ami.latest_ecs.id
  instance_type = var.ecs_instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_ec2_profile.name
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp2"
      volume_size           = 30
      delete_on_termination = true
      # encrypted             = true
      # kms_key_id            = var.kms_key_arn
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  user_data = base64encode(data.template_file.launch_template.rendered)
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "launch_template" {
  template = file("${path.module}/userdata.sh")
  vars = {
    ecs_cluster = aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_iam_role" "ecs_ec2_role" {
  name = "${var.stack}-${var.environment}-ecs-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# AWS Bedrock policy
resource "aws_iam_policy" "aws_bedrock_policy" {
  name        = "${var.stack}-${var.environment}-bedrock-access-policy"
  path        = "/"
  description = "${var.stack}-${var.environment}-bedrock-access-policy"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "bedrock:*",
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "bedrock_policy_attach" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = aws_iam_policy.aws_bedrock_policy.arn
}

// Attach AmazonSSMFullAccess policy
resource "aws_iam_role_policy_attachment" "ssm_full_access_attach" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

// Attach AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_managed_core_attach" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

// Attach AmazonEC2ContainerServiceforEC2Role policy
resource "aws_iam_role_policy_attachment" "ecs_service_ec2_role_attach" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

// Attach ComprehendFullAccess policy
resource "aws_iam_role_policy_attachment" "comprehend_full_access_attach" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/ComprehendFullAccess"
}

// Attach ComprehendMedicalFullAccess policy
resource "aws_iam_role_policy_attachment" "comprehend_medical_full_access_attach" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/ComprehendMedicalFullAccess"
}

resource "aws_iam_role_policy_attachment" "kms_power_access" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_instance_profile" "ecs_ec2_profile" {
  name = "${var.stack}-${var.environment}-ecs-ec2-instance-profile"
  role = aws_iam_role.ecs_ec2_role.name
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.stack}-${var.environment}-${var.workspace_backend}"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = local.pri_subnet_ids

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "${var.stack}-${var.environment}-${var.workspace_backend}"
    propagate_at_launch = true
  }
}

#########################
# IAM policy to use KMS #
#########################

# data "aws_iam_role" "asg_service_role" {
#   name = "AWSServiceRoleForAutoScaling"
# }

# resource "aws_iam_role_policy" "asg_kms_policy" {
#   name = "${var.stack}-${var.environment}-${var.workspace_backend}-asg-kms-policy"
#   role = data.aws_iam_role.asg_service_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid    = "AllowServiceLinkedRoleUseOfTheCustomerManagedKey",
#         Effect = "Allow",
#         Principal = {
#           AWS = [
#             "arn:aws:iam::${var.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
#           ]
#         },
#         Action = [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         Resource = "*"
#       },
#       {
#         Sid    = "AllowAttachmentOfPersistentResources",
#         Effect = "Allow",
#         Principal = {
#           AWS = [
#             "arn:aws:iam::${var.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
#           ]
#         },
#         Action   = ["kms:CreateGrant"],
#         Resource = "*",
#         Condition = {
#           Bool = {
#             "kms:GrantIsForAWSResource" = true
#           }
#         }
#       }
#     ]
#   })
# }