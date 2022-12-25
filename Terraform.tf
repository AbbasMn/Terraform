terraform {
  # Declares clude providers
  required_providers {
    aws = {  # all resource declaration should start as : aws_
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    # azure ={
    #      source  = "hashicorp/azure"        
    #     # blabla
    # }
  }
}

# Declare AWS region & API programming credentilas (Access key)
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAUQSOWV2UJMW4NVXR"
  secret_key = "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"
}

# Declare a custom VPC
resource "aws_vpc" "vpc-custom" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-custom"
    Stack = "production"
  }
}

# Declare an internet gateway(igw) for custom VPC
resource "aws_internet_gateway" "internetGatway-vpc-custom" {
  vpc_id = aws_vpc.vpc-custom.id
  tags = {
    Name = "internetGatway-vpc-custom"
    Stack = "production"      
  }
}

# Declare a custom route table
resource "aws_route_table" "routeTable-vpc-custom" {
  vpc_id = aws_vpc.vpc-custom.id
  route  {
    # carrier_gateway_id = "value"
      cidr_block = "0.0.0.0/0"   # defualt route => all traffic eill be sent to internet gateway  
      # core_network_arn = "value"
      # destination_prefix_list_id = "value"
      # egress_only_gateway_id = "value"
      gateway_id = aws_internet_gateway.internetGatway-vpc-custom.id
      # instance_id = "value"
      # ipv6_cidr_block = "value"
      # local_gateway_id = "value"
      # nat_gateway_id = "value"
      # network_interface_id = "value"
      # transit_gateway_id = "value"
      # vpc_endpoint_id = "value"
      # vpc_peering_connection_id = "value"
    } 
  route {
    ipv6_cidr_block = "::/0" # IPv6 defualt route
    gateway_id = aws_internet_gateway.internetGatway-vpc-custom.id        
  } 
  tags = {
    Name = "routeTable-vpc-custom"
    Stack = "production"      
  }
}

# Declare a private subnet in custom VPC as a DB private subnet
resource "aws_subnet" "db-subnet-private-vpc-custom" {
  vpc_id = aws_vpc.vpc-custom.id
  cidr_block = "10.0.0.0/24" 
  tags = {
    Name = "db-subnet-private-vpc-custom"
    Stack="production"
  }
}

# Declare an application public subnet
resource "aws_subnet" "app-subnet-public-vpc-custom" {
  vpc_id = aws_vpc.vpc-custom.id
  cidr_block = "10.0.1.0/24"
  # cidr_block = var.app-subnet-public-vpc-custom # => will ask you (prompt) to enter the valye for this variable whenever you apply
  availability_zone = "us-east-1a" # if don't hard coded AWS will assign a random AZ
  tags = {
      Name = "app-subnet-public-vpc-custom"
      Stack = "production"      
    }
}

# Invoke variabls file (terraform.tfvars) for fetching subnets cidr for following public subnets: test-application & dev-application 
# Declare a test-application public subnet
resource "aws_subnet" "test-app-subnet-public-vpc-custom" {
  vpc_id = aws_vpc.vpc-custom.id
  cidr_block = var.subnets_cidr[0].cidr_block
  availability_zone = "us-east-1a"
  tags = {
      Name = var.subnets_cidr[0].tag_name
      Stack = "test"      
    }
}

# Declare a dev-application public subnet
resource "aws_subnet" "dev-app-subnet-public-vpc-custom" {
  vpc_id = aws_vpc.vpc-custom.id
  cidr_block = var.subnets_cidr[1].cidr_block
  availability_zone = "us-east-1a"
  tags = {
      Name = var.subnets_cidr[1].tag_name
      Stack = "development"      
    }
}
 
# Associate subnet:app-subnet-public-vpc-custom with custom VPC route table
resource "aws_route_table_association" "routeTableAssociation-app-subnet-public-vpc-custom-with-routeTable-vpc-custom" {
  subnet_id = aws_subnet.app-subnet-public-vpc-custom.id
  route_table_id = aws_route_table.routeTable-vpc-custom.id
}

# Add a security group (Web & SSH traffic allowed) to pulic appplication subnet
resource "aws_security_group" "web-ssh-traffic-allowed-securityGroup-app-subnet-public-vpc-custom" {
  name        = "web-ssh-traffic-allowed-securityGroup-app-subnet-public-vpc-custom"
  description = "Allow web & SSH inbound traffic"
  vpc_id      = aws_vpc.vpc-custom.id

  ingress {
    description      = "HTTPS web trafic from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "HTTP web trafic from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "SSH trafic from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  # any protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "web-ssh-traffic-allowed-securityGroup-app-subnet-public-vpc-custom"
    Stack = "production"      
  }
}

# Attach a network interface to the public subnet: app-subnet-public-vpc-custom; then set an private IP for that.
resource "aws_network_interface" "networkInterface-app-subnet-public-vpc-custom" {
  subnet_id       = aws_subnet.app-subnet-public-vpc-custom.id
  private_ips     = ["10.0.1.50"] # cidr_block = "10.0.1.0/24"
  security_groups = [web-ssh-traffic-allowed-securityGroup-app-subnet-public-vpc-custom.id]

  # attachment {
  #   instance     = aws_instance.test.id
  #   device_index = 1
  # }
}