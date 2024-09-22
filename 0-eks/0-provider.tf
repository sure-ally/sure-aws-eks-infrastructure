
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.global_tags
  }
}

# Required for EKS
provider "tls" {
  proxy {
    from_env = true
  }
}

# Not required if you don't want to go with Helm. 
# Concepts that require Helm: 11-iam-oidc-lbc [AWS Load balancer Controller]
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.surek8scluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.surek8scluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.surek8scluster.name]
      command     = "aws"
    }
  }
}