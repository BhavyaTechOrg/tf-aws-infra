# Security Group for RDS Database
resource "aws_security_group" "database_security_group" {
  name        = "${var.name_prefix}-database-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  # Allow inbound traffic from application security group on PostgreSQL port (5432)
  ingress {
    description     = "Allow application instance to access RDS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application_security_group.id] # Ensure the EC2 SG is used
  }

  # Allow RDS to respond to traffic (Outbound)
  egress {
    description = "Allow outbound traffic to any destination"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_prefix}-database-security-group"
    Environment = var.environment
  }
}