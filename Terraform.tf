terraform {
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
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAUQSOWV2UJMW4NVXR"
  secret_key = "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"
}
resource "aws_vpc" "vpc-custom" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-custom"
    Stack = "production"
  }
}

resource "aws_internet_gateway" "internetGatway-vpc-custom" {
  vpc_id = aws_vpc.vpc-custom.id
  tags = {
    Name = "internetGatway-vpc-custom"
    Stack = "production"      
  }
}

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

resource "aws_subnet" "DB-subnet-private-vpc-custom" {
  vpc_id = aws_vpc.vpc-custom.id
  cidr_block = "10.0.0.0/24" 
  tags = {
    Name = "subnet-private-vpc-custom"
    Stack="production"
  }
}


