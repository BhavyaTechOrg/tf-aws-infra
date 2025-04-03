resource "aws_launch_template" "webapp_template" {
  name_prefix   = "webapp-lt-${var.environment}-${random_id.suffix.hex}-"
  image_id      = var.custom_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_app_sg.id]
  }

  user_data = base64encode(file("user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "webapp-${var.environment}-${random_id.suffix.hex}"
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "webapp-volume-${var.environment}-${random_id.suffix.hex}"
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
