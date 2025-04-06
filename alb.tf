
# ----------------------
# 2. Application Load Balancer
# ----------------------
resource "aws_lb" "app_lb" {
  name               = "app-lb-${var.environment}-${random_id.suffix.hex}"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name        = "app-lb-${var.environment}-${random_id.suffix.hex}"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------
# 3. Target Group
# ----------------------
resource "aws_lb_target_group" "app_tg" {
  name        = "app-tg-${var.environment}-${random_id.suffix.hex}"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "app-tg-${var.environment}-${random_id.suffix.hex}"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------
# 4. HTTP Listener
# ----------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}
