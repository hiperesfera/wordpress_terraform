
output "wordpress_elb" {
  value = aws_elb.wordpress_elb.id
}

output "wordpress_elb_dns_name" {
  value       = aws_elb.wordpress_elb.dns_name
  description = "The domain name of the load balancer"
}
