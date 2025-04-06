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

  user_data = base64encode(<<EOF
#!/bin/bash
set -euxo pipefail
exec > /var/log/user-data.log 2>&1

echo "Starting EC2 user data script..."

# Set values using Terraform interpolation
POSTGRESQL_HOST="${aws_db_instance.webapp_db.address}"
POSTGRESQL_PORT=5432
POSTGRESQL_USER="${jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["username"]}"
POSTGRESQL_PASSWORD="${jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["password"]}"
POSTGRESQL_DB="${var.db_name}"
S3_BUCKET_NAME="${aws_s3_bucket.webapp_s3.bucket}"

# Create env file with escaped variables
cat > /tmp/webapp.env <<EOL
POSTGRESQL_HOST=$${POSTGRESQL_HOST}
POSTGRESQL_PORT=$${POSTGRESQL_PORT}
POSTGRESQL_USER=$${POSTGRESQL_USER}
POSTGRESQL_PASSWORD=$${POSTGRESQL_PASSWORD}
POSTGRESQL_DB=$${POSTGRESQL_DB}
S3_BUCKET_NAME=$${S3_BUCKET_NAME}
EOL

sudo mv /tmp/webapp.env /etc/webapp.env
sudo chmod 600 /etc/webapp.env
id -u csye6225 &>/dev/null && sudo chown csye6225:csye6225 /etc/webapp.env || echo "⚠️ csye6225 user not found"

# Create log directory
sudo mkdir -p /var/log/webapp
sudo chown csye6225:csye6225 /var/log/webapp
sudo chmod 755 /var/log/webapp

# CloudWatch Agent config
cat <<CWJSON > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/webapp/app.log",
            "log_group_name": "/webapp/application_logs",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/webapp/userdata_logs",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "statsd": {
        "service_address": ":8125"
      }
    }
  }
}
CWJSON

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a append-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# Restart service
sudo systemctl daemon-reload
sudo systemctl restart webapp.service

echo "User data script completed successfully!"
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