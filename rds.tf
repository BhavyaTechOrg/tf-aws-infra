# Fetch the database credentials from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_credentials" {
  name = "db/credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

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
  username               = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["username"]
  password               = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["password"]
  parameter_group_name   = aws_db_parameter_group.rds_param_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = true

  # Ensures the RDS is placed in the correct subnets within the VPC
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name        = "csye6225-db"
    Environment = var.environment
  }
}
