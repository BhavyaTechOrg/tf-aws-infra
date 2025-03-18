resource "aws_security_group" "application_security_group" {
  name        = "${var.name_prefix}-application-security-group"
  description = "Security group for the web application"
  vpc_id      = aws_vpc.main.id # Ensuring the security group is in the correct VPC

  # Allow SSH (Port 22) from anywhere (should restrict to specific IPs in production)
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this in production
  }

  # Allow HTTP (Port 80) from anywhere
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (Port 443) from anywhere
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow application port (e.g., 3000 for Node.js)
  ingress {
    description = "Allow application traffic"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this in production
  }

  # Allow all outgoing traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ensure Terraform does not accidentally delete this resource
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }

  tags = {
    Name        = "${var.name_prefix}-application-security-group"
    Environment = var.environment
  }
}
