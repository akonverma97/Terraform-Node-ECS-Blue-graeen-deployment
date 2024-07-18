########################
# ECR REPOSITORY       #
########################

data "aws_iam_policy_document" "assume_by_ecr" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecr" {
  name               = "${var.stack}-${var.environment}-${var.workspace_backend}-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecr.json
}

resource "aws_ecr_repository" "ecr" {
  name = "${var.stack}-${var.environment}-${var.workspace_backend}"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": [
          "v"
        ],
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

#####################
# ECS CLUSTER       #
#####################

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.stack}-${var.environment}-${var.workspace_backend}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


###########################
# ECS Security group      #
###########################

resource "aws_security_group" "ecs_sg" {
  name   = "${var.stack}-${var.environment}-${var.workspace_backend}-ecs-sg"
  vpc_id = local.vpc_id

  ingress {
    from_port       = 32768
    protocol        = "tcp"
    to_port         = 65535
    security_groups = [aws_security_group.application_security_group.id]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################
# ECS SERVICE                 #
###############################

resource "aws_ecs_service" "ecs" {
  name            = "${var.stack}-${var.environment}-${var.workspace_backend}"
  task_definition = aws_ecs_task_definition.taskdef.id
  cluster         = aws_ecs_cluster.ecs_cluster.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_primary.arn
    container_name   = "${var.stack}-${var.environment}-${var.workspace_backend}"
    container_port   = var.container_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  launch_type                        = "EC2"
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer
    ]
  }
}

#########################
# TASK DEFINITION       #
#########################

resource "aws_iam_role" "taskdefexecution" {
  name        = "${var.stack}-${var.environment}-${var.workspace_backend}-taskdefexecution"
  description = "${var.stack}-${var.environment}-${var.workspace_backend}-taskdefexecution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "taskdefexecution_role_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ])
  role       = aws_iam_role.taskdefexecution.name
  policy_arn = each.value
}

resource "aws_ecs_task_definition" "taskdef" {
  family                   = "${var.stack}-${var.environment}-${var.workspace_backend}"
  execution_role_arn       = aws_iam_role.taskdefexecution.arn
  requires_compatibilities = ["EC2"]
  memory                   = var.memory
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "${var.stack}-${var.environment}-${var.workspace_backend}",
    "portMappings": [
      {
        "hostPort": 0,
        "protocol": "tcp",
        "containerPort": ${var.container_port}
      }
    ],
    "image": "${aws_ecr_repository.ecr.repository_url}:latest",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.stack}-${var.environment}-${var.workspace_backend}",
        "awslogs-region": "${var.region_primary}",
        "awslogs-stream-prefix": "ecs",
        "awslogs-create-group": "true"
      }
    },
    "tags": [
      {
        "key": "application",
        "value": "${var.workspace_backend}"
      },
      {
        "key": "environment",
        "value": "${var.environment}"
      },
      {
        "key": "stack",
        "value": "${var.stack}"
      }
    ]
  }
]
TASK_DEFINITION
}

##########################
# ECS Autoscaling        #
##########################

resource "aws_appautoscaling_target" "ecs_target" {
  depends_on         = [aws_ecs_service.ecs]
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_target_policy" {
  name               = "${aws_ecs_service.ecs.name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 95
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "memory_target_policy" {
  depends_on         = [aws_ecs_service.ecs]
  name               = "${aws_ecs_service.ecs.name}-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 95
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}


