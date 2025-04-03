output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.webapp_db.endpoint
}
