# OIDC provider is common for all Service Accounts
# provider registry.terraform.io/hashicorp/tls: required 
data "tls_certificate" "sure_k8s_cluster_cert" {
  url = aws_eks_cluster.sure_k8s_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "sure_k8s_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"] # OIDC + IAM send token and role so STS will send back the temp creds to EKS
  thumbprint_list = [data.tls_certificate.sure_k8s_cluster_cert.certificates[0].sha1_fingerprint] # EKS should contact OIDC provider
  url             = aws_eks_cluster.sure_k8s_cluster.identity[0].oidc[0].issuer # OIDC Service url taken from EKS so that it can sync with EKS
}
