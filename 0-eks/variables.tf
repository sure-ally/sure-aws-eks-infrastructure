
# Global variables

variable "global_tags" {
  type = map(string)
  default = {
    "ManagedBy"   = "Terraform"
    "Environment" = "dev"
  }
}

variable "lbc_service_account_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "AWS Load Balancer Controller service account name"
}
