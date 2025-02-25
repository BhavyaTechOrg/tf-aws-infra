resource "aws_instance" "application_instance" {
  ami                         = var.custom_ami # Custom AMI from Packer
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public[*].id, 0)
  vpc_security_group_ids      = [aws_security_group.application-security-group.id] # Attaching security group
  associate_public_ip_address = true                                               # Ensuring instance is accessible

  # Ensure EBS volume terminates with instance
  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false # Allows termination

  tags = {
    Name        = "${var.name_prefix}-application-instance"
    Environment = var.environment
  }
}
