#################################
# APPLICATION LOAD BALANCER     #
#################################

resource "aws_security_group" "application_security_group" {
  name   = "${var.stack}-${var.environment}-${var.workspace_backend}-alb-sg"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = var.cidr_blocks
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "application_load_balancer" {
  name                       = "${var.stack}-${var.environment}-${var.workspace_backend}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.application_security_group.id]
  subnets                    = local.pub_subnet_ids
  enable_deletion_protection = false
  idle_timeout               = "300"
  tags = {
    "stack"         = var.stack
    "stack_env"     = var.environment
    "waf-exception" = "silverline"
  }
}

# alb http listener 
resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_primary.arn
  }
  lifecycle {
    ignore_changes = [default_action]
  }
}

resource "aws_lb_target_group" "target_group_primary" {
  name        = "${var.stack}-${var.environment}-${var.workspace_backend}-blue"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = local.vpc_id
  health_check {
    path    = var.health_check_path
    matcher = "200-499"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "target_group_secondary" {
  name        = "${var.stack}-${var.environment}-${var.workspace_backend}-green"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = local.vpc_id
  health_check {
    path    = var.health_check_path
    matcher = "200-499"
  }
  lifecycle {
    create_before_destroy = true
  }
}
