variable "security_groups" {}
variable "subnet_id" {}
variable "user_data" {}

#### Creating Consul Server on Ubuntu Server
resource "aws_instance" "server" {
  ami           = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  associate_public_ip_address = false
  security_groups = var.security_groups
  subnet_id = var.subnet_id
  user_data = var.user_data

  tags = {
    Name = "wordpress"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "server_id" {
  value = aws_instance.server.id
}

output "server_ip" {
  value = aws_instance.server.public_ip
}
