
# SSL Certificate Configuration
# 1. Use the most recent issued certificate for dev environment
data "aws_acm_certificate" "dev_cert" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

# 2. HTTPS Listener for the Load Balancer
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  # Conditional ARN based on environment
  certificate_arn = var.environment == "dev" ? data.aws_acm_certificate.dev_cert.arn : var.imported_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}
