# Bootsratping a Wordpress using Terraform

This is an example of how to deploy a Wordpress instance in AWS using Terraform. The Wordpress deployment is done in a private EC2 instance with outbound access managed via NAT gateway. Access to Wordpress application is done via AWS Classic load balancer which can be complemented with a WAF

The deployment also installs a local SMTP service for outbound email notifications. This is used to send the admin password to the same mails address provided during the Wordpress installation. 
