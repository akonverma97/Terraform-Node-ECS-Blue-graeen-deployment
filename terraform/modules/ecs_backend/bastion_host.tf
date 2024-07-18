resource "aws_security_group" "bastion_sg" {
  name        = "${var.stack}-${var.environment}-bastion-sg"
  description = "${var.stack} ${var.environment} Bastion security group"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.15.64.76/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}