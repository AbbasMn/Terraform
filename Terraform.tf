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