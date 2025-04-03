# #!/bin/bash
# set -e
# exec > /var/log/user-data.log 2>&1

# echo "Starting EC2 user data script..."

# # Export environment variables
# export POSTGRESQL_HOST=${POSTGRESQL_HOST}
# export POSTGRESQL_PORT=5432
# export POSTGRESQL_USER=${POSTGRESQL_USER}
# export POSTGRESQL_PASSWORD=${POSTGRESQL_PASSWORD}
# export POSTGRESQL_DB=${POSTGRESQL_DB}
# export S3_BUCKET_NAME=${S3_BUCKET_NAME}

# # Create env file
# cat > /tmp/webapp.env << EOL
# POSTGRESQL_HOST=$POSTGRESQL_HOST
# POSTGRESQL_PORT=$POSTGRESQL_PORT
# POSTGRESQL_USER=$POSTGRESQL_USER
# POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD
# POSTGRESQL_DB=$POSTGRESQL_DB
# S3_BUCKET_NAME=$S3_BUCKET_NAME
# EOL

# sudo mv /tmp/webapp.env /etc/webapp.env
# sudo chmod 600 /etc/webapp.env
# sudo chown csye6225:csye6225 /etc/webapp.env

# # Create /var/log/webapp for Winston logs
# sudo mkdir -p /var/log/webapp
# sudo chown csye6225:csye6225 /var/log/webapp
# sudo chmod 755 /var/log/webapp

# # Update systemd service to load env file
# sudo sed -i 's/Environment="POSTGRESQL_DB=.*"//' /etc/systemd/system/webapp.service
# sudo sed -i 's/Environment="POSTGRESQL_USER=.*"//' /etc/systemd/system/webapp.service
# sudo sed -i 's/Environment="POSTGRESQL_PASSWORD=.*"//' /etc/systemd/system/webapp.service
# sudo sed -i '/\[Service\]/a EnvironmentFile=/etc/webapp.env' /etc/systemd/system/webapp.service

# # Write CloudWatch Agent config
# echo "Configuring CloudWatch Agent..."
# cat <<CWJSON > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
# {
#   "logs": {
#     "logs_collected": {
#       "files": {
#         "collect_list": [
#           {
#             "file_path": "/var/log/webapp/app.log",
#             "log_group_name": "/webapp/application_logs",
#             "log_stream_name": "{instance_id}"
#           },
#           {
#             "file_path": "/var/log/user-data.log",
#             "log_group_name": "/webapp/userdata_logs",
#             "log_stream_name": "{instance_id}"
#           }
#         ]
#       }
#     }
#   },
#   "metrics": {
#     "metrics_collected": {
#       "statsd": {
#         "service_address": ":8125"
#       }
#     }
#   }
# }
# CWJSON

# # Start CloudWatch Agent
# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#   -a fetch-config \
#   -m ec2 \
#   -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
#   -s

# # Restart webapp service
# sudo systemctl daemon-reload
# sudo systemctl restart webapp.service

# echo "User data script completed successfully!"
