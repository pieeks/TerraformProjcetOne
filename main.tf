terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Wir erstellen ein leeres VPC (virtuelles privates Netzwerk)
resource "aws_vpc" "test_netzwerk" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MeinCachyOSTestNetzwerk"
  }
}
