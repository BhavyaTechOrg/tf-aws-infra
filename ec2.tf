# resource "aws_instance" "application_instance" {
#   ami                         = var.custom_ami # Custom AMI built with Packer
#   instance_type               = "t2.micro"
#   subnet_id                   = element(aws_subnet.public[*].id, 0) # Using public subnet
#   vpc_security_group_ids      = [aws_security_group.asg_app_sg.id]
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

#   root_block_device {
#     volume_size           = 25
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }

#   disable_api_termination = false

#   user_data = <<-EOF
#     #!/bin/bash
#     set -e
#     exec > /var/log/user-data.log 2>&1

#     echo "Starting EC2 user data script..."

#     # Export environment variables
#     export POSTGRESQL_HOST=${aws_db_instance.webapp_db.address}
#     export POSTGRESQL_PORT=5432
#     export POSTGRESQL_USER=${jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["username"]}
#     export POSTGRESQL_PASSWORD=${jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["password"]}
#     export POSTGRESQL_DB=${var.db_name}
#     export S3_BUCKET_NAME="webapp-${random_uuid.bucket_name.result}"

#     # Create env file
#     cat > /tmp/webapp.env << EOL
#     POSTGRESQL_HOST=$${POSTGRESQL_HOST}
#     POSTGRESQL_PORT=$${POSTGRESQL_PORT}
#     POSTGRESQL_USER=$${POSTGRESQL_USER}
#     POSTGRESQL_PASSWORD=$${POSTGRESQL_PASSWORD}
#     POSTGRESQL_DB=$${POSTGRESQL_DB}
#     S3_BUCKET_NAME=$${S3_BUCKET_NAME}
#     EOL

#     sudo mv /tmp/webapp.env /etc/webapp.env
#     sudo chmod 600 /etc/webapp.env
#     sudo chown csye6225:csye6225 /etc/webapp.env

#     # Create /var/log/webapp for Winston logs
#     sudo mkdir -p /var/log/webapp
#     sudo chown csye6225:csye6225 /var/log/webapp
#     sudo chmod 755 /var/log/webapp

#     # Update systemd service to load env file
#     sudo sed -i 's/Environment="POSTGRESQL_DB=.*"//' /etc/systemd/system/webapp.service
#     sudo sed -i 's/Environment="POSTGRESQL_USER=.*"//' /etc/systemd/system/webapp.service
#     sudo sed -i 's/Environment="POSTGRESQL_PASSWORD=.*"//' /etc/systemd/system/webapp.service
#     sudo sed -i '/\\[Service\\]/a EnvironmentFile=/etc/webapp.env' /etc/systemd/system/webapp.service

#     # Write CloudWatch Agent config
#     echo "Configuring CloudWatch Agent..."
#     cat <<CWJSON > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
#     {
#       "logs": {
#         "logs_collected": {
#           "files": {
#             "collect_list": [
#               {
#                 "file_path": "/var/log/webapp/app.log",
#                 "log_group_name": "/webapp/application_logs",
#                 "log_stream_name": "{instance_id}"
#               },
#               {
#                 "file_path": "/var/log/user-data.log",
#                 "log_group_name": "/webapp/userdata_logs",
#                 "log_stream_name": "{instance_id}"
#               }
#             ]
#           }
#         }
#       },
#       "metrics": {
#         "metrics_collected": {
#           "statsd": {
#             "service_address": ":8125"
#           }
#         }
#       }
#     }
#     CWJSON

#     # Start CloudWatch Agent
#     /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#       -a fetch-config \
#       -m ec2 \
#       -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
#       -s

#     # Restart webapp service
#     sudo systemctl daemon-reload
#     sudo systemctl restart webapp.service

#     echo "User data script completed successfully!"
#   EOF

#   tags = {
#     Name        = "${var.name_prefix}-application-instance"
#     Environment = var.environment
#   }
# }
