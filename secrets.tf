# Create a new AWS Secrets Manager secret for DB credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "db/credentials-${random_id.suffix.hex}"
  kms_key_id              = aws_kms_key.secrets_key.arn
  recovery_window_in_days = 0 # Set to 0 for testing, use 7-30 for production

  tags = {
    Name        = "${var.name_prefix}-db-credentials"
    Environment = var.environment
  }
}

# Generate a secure random password for the database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = random_password.db_password.result
}
