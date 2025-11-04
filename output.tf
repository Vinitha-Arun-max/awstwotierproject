output "alb_dns_name" {
 description = "Application load balancer DNS"
 value = aws_lb.alb.dns_name
}

output "route53_app_url" {
 description = "App Domain"
 value = "app.${var.domain_name}"
}

output "db_endpoint" {
 description = "Database Endpoint"
 value = aws_db_instance.db.address
}
