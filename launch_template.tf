resource "aws_launch_template" "webapp_template" {
  name_prefix   = "webapp-lt-${var.environment}-${random_pet.suffix.id}-"
  image_id      = var.custom_ami
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_app_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    exec > /var/log/user-data.log 2>&1

    echo "=== Starting EC2 bootstrap ==="

    apt update -y
    apt install -y awscli jq postgresql-client

    echo "Fetching credentials from Secrets Manager..."
    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --secret-id "db/credentials" \
      --region ${var.aws_region} \
      --query SecretString \
      --output text)

    if [ -z "$SECRET_JSON" ]; then
      echo "❌ Failed to fetch secret"
      exit 1
    fi

    DB_USERNAME=$(echo "$SECRET_JSON" | jq -r .username)
    DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r .password)
    DB_NAME=$(echo "$SECRET_JSON" | jq -r .db_name)

    echo "✅ Got DB credentials: $DB_USERNAME"

    cat > /etc/webapp.env <<EOL
NODE_ENV=production
PORT=${var.application_port}
POSTGRESQL_HOST=${aws_db_instance.webapp_db.address}
POSTGRESQL_PORT=5432
POSTGRESQL_USER=$DB_USERNAME
POSTGRESQL_PASSWORD=$DB_PASSWORD
POSTGRESQL_DB=$DB_NAME
DATABASE_URL=postgresql://$DB_USERNAME:$DB_PASSWORD@${aws_db_instance.webapp_db.address}:5432/$DB_NAME
S3_BUCKET_NAME=webapp-${random_uuid.bucket_name.result}
AWS_REGION=${var.aws_region}
EOL

    chmod 600 /etc/webapp.env
    chown csye6225:csye6225 /etc/webapp.env

    echo "✅ /etc/webapp.env written"

    echo "🔍 Ensuring EnvironmentFile is in webapp.service"
    if ! grep -q "EnvironmentFile=/etc/webapp.env" /etc/systemd/system/webapp.service; then
      sed -i '/\\[Service\\]/a EnvironmentFile=/etc/webapp.env' /etc/systemd/system/webapp.service
    fi

    echo "✅ Reloading and starting webapp.service"
    systemctl daemon-reload
    systemctl enable webapp.service
    systemctl restart webapp.service

    echo "== webapp.service status =="
    systemctl status webapp.service --no-pager

    echo "=== Testing DB connection ==="
    source /etc/webapp.env
    PGPASSWORD=$DB_PASSWORD psql -h $POSTGRESQL_HOST -U $DB_USERNAME -d $DB_NAME -c "SELECT 1" || echo "❌ DB connection failed"

    echo "=== EC2 bootstrap completed ==="
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "webapp-${var.environment}-${random_pet.suffix.id}"
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "webapp-volume-${var.environment}-${random_pet.suffix.id}"
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
