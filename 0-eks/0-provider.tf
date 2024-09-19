# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.global_tags
  }
}

provider "tls" {
  proxy {
    from_env = true
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65"
    }
  }
}