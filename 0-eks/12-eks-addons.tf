# Next step of OIDC to get rid off OIDC
# Pod Identity is a simpler method than IAM roles for service accounts, as this method doesn’t use OIDC identity providers. 
# Additionally, you can configure a role for Pod Identity once, and reuse it across clusters.
resource "aws_eks_addon" "sure_k8s_pod_identity" {
  cluster_name  = aws_eks_cluster.surek8scluster.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.2-eksbuild.2" # get by running - aws eks describe-addon-versions --region us-east-1 --addon-name eks-pod-identity-agent
}