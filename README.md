# terraform-aws-dev-environment

This is just a simple project to show how you can create an dev environment in AWS using Terraform. The project uses arguments to set up the VPC, networking, and EC2 necessary for the environment. It also uses the user_data arguments to load Docker onto the EC2 instance upon startup. This will make it easy to start and stop the instance as necessary without incurring unnecessary costs. 
