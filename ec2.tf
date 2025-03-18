resource "aws_instance" "application_instance" {
  ami                         = var.custom_ami # Custom AMI built with Packer
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public[*].id, 0) # Using public subnet
  vpc_security_group_ids      = [aws_security_group.application_security_group.id]
  associate_public_ip_address = true                                      # Required for internet access
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name # Ensure IAM Profile is correct

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false

  # # User Data script - Runs on instance launch
  # user_data = <<-EOF
  #   #!/bin/bash
  #   set -e  # Exit on error
  #   exec > /var/log/user-data.log 2>&1  # Log output for debugging

  #   echo "Starting EC2 user data script..."

  #   # Install dependencies
  #   echo "Installing dependencies..."
  #   sudo apt-get update -y
  #   sudo apt-get install -y jq unzip awscli

  #   # Fetch database credentials from AWS Secrets Manager
  #   echo "Fetching database credentials..."
  #   DB_SECRET=$(aws secretsmanager get-secret-value --secret-id db/credentials --query SecretString --output text || echo "ERROR")

  #   if [[ "$DB_SECRET" == "ERROR" ]]; then
  #     echo "Failed to fetch DB credentials. Exiting..."
  #     exit 1
  #   fi

  #   # Extract credentials using jq
  #   POSTGRESQL_USER=$(echo "$DB_SECRET" | jq -r '.username')
  #   POSTGRESQL_PASSWORD=$(echo "$DB_SECRET" | jq -r '.password')
  #   POSTGRESQL_DB=$(echo "$DB_SECRET" | jq -r '.db_name')

  #   # Validate credentials
  #   if [[ -z "$POSTGRESQL_USER" || -z "$POSTGRESQL_PASSWORD" || -z "$POSTGRESQL_DB" ]]; then
  #     echo "Missing required DB credentials. Exiting..."
  #     exit 1
  #   fi

  #   # Write environment variables securely
  #   echo "Setting environment variables..."
  #   echo "POSTGRESQL_HOST=${aws_db_instance.webapp_db.endpoint}" | sudo tee -a /etc/environment
  #   echo "POSTGRESQL_USER=$POSTGRESQL_USER" | sudo tee -a /etc/environment
  #   echo "POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD" | sudo tee -a /etc/environment
  #   echo "POSTGRESQL_DB=$POSTGRESQL_DB" | sudo tee -a /etc/environment

  #   # Restart application service
  #   echo "Restarting web application service..."
  #   sudo systemctl restart webapp.service || echo "Service restart failed!"

  #   echo "User data script completed successfully!"
  # EOF

  user_data = <<-EOF
#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1

echo "Starting EC2 user data script..."

# Create environment file specifically for the webapp service
cat > /tmp/webapp.env << EOL
POSTGRESQL_HOST=${aws_db_instance.webapp_db.address}
POSTGRESQL_PORT=5432
POSTGRESQL_USER=${jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["username"]}
POSTGRESQL_PASSWORD=${jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["password"]}
POSTGRESQL_DB=${var.db_name}
EOL

# Move file to correct location with appropriate permissions
sudo mv /tmp/webapp.env /etc/webapp.env
sudo chmod 600 /etc/webapp.env
sudo chown csye6225:csye6225 /etc/webapp.env

# Modify the systemd service file to use EnvironmentFile
sudo sed -i 's/Environment="POSTGRESQL_DB=.*"//' /etc/systemd/system/webapp.service
sudo sed -i 's/Environment="POSTGRESQL_USER=.*"//' /etc/systemd/system/webapp.service
sudo sed -i 's/Environment="POSTGRESQL_PASSWORD=.*"//' /etc/systemd/system/webapp.service
sudo sed -i '/\[Service\]/a EnvironmentFile=/etc/webapp.env' /etc/systemd/system/webapp.service

# Reload systemd daemon and restart service
sudo systemctl daemon-reload
sudo systemctl restart webapp.service

echo "User data script completed successfully!"
EOF
  tags = {
    Name        = "${var.name_prefix}-application-instance"
    Environment = var.environment
  }
}
