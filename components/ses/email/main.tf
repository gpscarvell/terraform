resource "aws_ses_email_identity" "main" {
  email = var.email
}
