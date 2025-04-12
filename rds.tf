# Create an RDS Subnet Group (Ensures RDS is deployed in the correct subnets within the VPC)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id # Ensuring that RDS uses private subnets

  tags = {
    Name = "RDS Subnet Group"
  }
}

# Create an RDS parameter group
resource "aws_db_parameter_group" "rds_param_group" {
  name   = "csye6225-rds-param-group"
  family = "postgres14" # Ensure this matches your Postgres version

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = {
    Name        = "csye6225-rds-param-group"
    Environment = var.environment
  }
}

# Create the RDS Instance
resource "aws_db_instance" "webapp_db" {
  identifier             = "csye6225"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = "csye6225"
  password               = random_password.db_password.result
  parameter_group_name   = aws_db_parameter_group.rds_param_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = true

  # Ensures the RDS is placed in the correct subnets within the VPC
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  # Enable storage encryption with KMS
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn

  # Add dependency to wait for KMS key
  depends_on = [aws_kms_key.rds_key]


  tags = {
    Name        = "csye6225-db"
    Environment = var.environment
  }
}
