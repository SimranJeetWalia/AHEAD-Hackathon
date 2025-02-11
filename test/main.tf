Here's the Terraform code to create the infrastructure based on the provided architecture diagram and configuration:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"  # Change this to your desired region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "my-vpc"
  cidr = "192.168.0.0/16"

  azs             = ["us-west-2a"]
  public_subnets  = ["192.168.1.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "web-server"

  ami                    = "ami-085ad6ae776d8f09c"
  instance_type          = "t3.micro"
  key_name               = "my-key-pair"  # Make sure to create or specify an existing key pair
  monitoring             = true
  vpc_security_group_ids = [module.web_server_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "web-server-sg"
  description = "Security group for web server"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_internet_gateway" "main" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = module.vpc.public_subnets[0]
  route_table_id = aws_route_table.public.id
}
```

This Terraform code creates:

1. A VPC with the specified CIDR block
2. A public subnet within the VPC
3. An EC2 instance (web server) in the public subnet
4. A security group for the web server allowing inbound HTTP, HTTPS, and SSH traffic
5. An Internet Gateway
6. A route table for the public subnet with a route to the Internet Gateway

Note that this code doesn't include Route53 configuration as it was specified to skip in the provided parameters. Also, no additional services, scalability options, or specific security configurations were added beyond the basic setup, as per the given parameters.

Remember to initialize Terraform, review the plan, and apply the changes in your desired AWS environment. Also, ensure you have the necessary AWS credentials configured for Terraform to access your AWS account.