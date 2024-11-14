output "arn" {
  value       = aws_ses_email_identity.main.arn
  description = "The ARN of the email identity."
}
