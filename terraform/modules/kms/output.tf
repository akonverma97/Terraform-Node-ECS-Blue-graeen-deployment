output "kms_key_arn" {
  description = "Output the value of the KMS key arn"
  value       = aws_kms_key.encryption_key.arn
}