# VARIABLES
variable "vpc" {}
variable "subnets" {}

# RESOURCES
# create security groups consult_connect
resource "aws_security_group" "wordpress_server" {
  name        = "wordpress_server"
  description = "wordpress security group"
  vpc_id      = var.vpc

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

# create security groups consult_connect ELB
resource "aws_security_group" "wordpress_elb" {
  name        = "wordpress_elb"
  description = "wordpress ELB security group"
  vpc_id      = var.vpc

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}


# OUTPUT
output "wordpress_elb_security_group" {
  value = aws_security_group.wordpress_elb.id
}

output "wordpress_server_security_group" {
  value = aws_security_group.wordpress_server.id
}
