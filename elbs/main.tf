
### Creating ELB
resource "aws_elb" "wordpress_elb" {
  name = "wordpress-elb"
  security_groups = var.security_groups
  subnets = var.subnets

health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "TCP:80"
}

  listener {
    lb_port = 80
    lb_protocol = "tcp"
    instance_port = "80"
    instance_protocol = "tcp"
  }
}
