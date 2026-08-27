terraform {
  cloud {
    organization = "PingTraceSSH"
    workspaces {
      name = "aws-terraform-network-lab"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}