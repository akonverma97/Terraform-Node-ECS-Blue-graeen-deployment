
output "ecs_sg" {
  description = "Output value of the Sg of ECS"
  value       = aws_security_group.ecs_sg.id
}

output "codebuild_arn" {
  description = "Output value of the codebuild arn"
  value       = aws_iam_role.backendcodebuild.arn
}

output "ecs_ec2_role_arn" {
  description = "Output value of the ecs ec2 role arn"
  value       = aws_iam_role.ecs_ec2_role.arn
}
