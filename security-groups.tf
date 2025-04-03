# ----------------------
# Random Pet Generator for Unique Names
# ----------------------
resource "random_pet" "suffix" {
  length = 2
}

# ----------------------
# 1. Load Balancer Security Group
# ----------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.environment}-${random_pet.suffix.id}"
  description = "Allow inbound HTTP/HTTPS to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from public"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-sg-${var.environment}-${random_pet.suffix.id}"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------
# 2. Application EC2 Security Group (for ASG instances)
# ----------------------
resource "aws_security_group" "asg_app_sg" {
  name        = "asg-app-sg-${var.environment}-${random_pet.suffix.id}"
  description = "Allow traffic from ALB and SSH to EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow application traffic from ALB"
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Allow SSH from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }



  tags = {
    Name        = "asg-app-sg-${var.environment}-${random_pet.suffix.id}"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------
# 3. RDS Security Group (if EC2s need DB access)
# ----------------------
resource "aws_security_group" "database_security_group" {
  name        = "rds-sg-${var.environment}-${random_pet.suffix.id}"
  description = "Allow access to RDS from ASG EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow PostgreSQL from EC2 app SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.asg_app_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds-sg-${var.environment}-${random_pet.suffix.id}"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}
