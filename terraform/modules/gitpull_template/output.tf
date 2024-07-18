output "source_code_bucket" {
  description = "Output the value of the source code bucket"
  value       = aws_cloudformation_stack.gitpull_cf.outputs["OutputBucketName"]
}