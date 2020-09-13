provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


data "template_file" "wordpress_install" {
  template = "${file("./bootstrap_scripts/wordpress_install.sh")}"
  vars = {
    site_url_name = "${module.elbs.wordpress_elb_dns_name}"
  }
}


module "vpc" {
      source = "./vpc"
      availabilityZone = var.availabilityZone
      region           = var.region
}


module "acls" {
      source = "./acls"
      vpc = module.vpc.vpc_id
      subnets = [module.vpc.public_subnet_id]
}


module "elbs" {
      source = "./elbs"
      security_groups = [module.acls.wordpress_elb_security_group]
      subnets = [module.vpc.public_subnet_id]
}


module "wordpress_server" {
      source = "./wordpress_server"
      security_groups = [module.acls.wordpress_server_security_group]
      subnet_id = module.vpc.private_subnet_id
      user_data = "${data.template_file.wordpress_install.rendered}"
}

# Create a new load balancer attachment
resource "aws_elb_attachment" "aws_wordpress_server_elb_attachment" {
  elb      = module.elbs.wordpress_elb
  instance = module.wordpress_server.server_id
}


output "dashboard_server_elb_dns_name" {
  value       = module.elbs.wordpress_elb_dns_name
  description = "The domain name of the load balancer"
}


output "wordpress_public_ip" {
  value       = module.wordpress_server.server_ip
  description = "wordpress public IP"
}
