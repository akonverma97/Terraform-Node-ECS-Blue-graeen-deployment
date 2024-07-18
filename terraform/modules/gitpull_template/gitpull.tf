resource "aws_cloudformation_stack" "gitpull_cf" {
  name = "${var.stack}-${var.environment}-${var.workspace}-gitpull"
  parameters = {
    AllowedIps       = "0.0.0.0/0",
    OutputBucketName = "${var.stack}-${var.environment}-${var.workspace}-source-code"
  }

  template_body = file("${path.module}/ssh.yml")
  capabilities  = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
  lifecycle {
    ignore_changes = all
  }
}