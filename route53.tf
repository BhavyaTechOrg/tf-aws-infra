# 1. Lookup the existing hosted zone (e.g., bhavyacloud.tech)
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

# 3. A-record for dev.bhavyacloud.tech → ALB
resource "aws_route53_record" "dev_app_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}


