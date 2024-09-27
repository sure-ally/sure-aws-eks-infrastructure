# See the comments of aws_eks_pod_identity_association
# data "aws_iam_policy_document" "sure_k8s_aws_lbc_assume_role_policy" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# IAM role and SA association -- through OIDC. 
data "aws_iam_policy_document" "sure_k8s_aws_lbc_assume_role_policy" {

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.surek8soidcprovider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.surek8soidcprovider.url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:${var.lbc_service_account_name}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.surek8soidcprovider.url, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

  }
}

resource "aws_iam_role" "sure_k8s_aws_lbc_role" {
  name               = "${aws_eks_cluster.surek8scluster.name}-aws-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.sure_k8s_aws_lbc_assume_role_policy.json
}

resource "aws_iam_policy" "sure_k8s_aws_lbc_policy" {
  policy = file("./files/AWSLoadBalancerController.json")
  name   = "sure-k8s-aws-lbc-policy"
}

resource "aws_iam_role_policy_attachment" "sure_k8s_aws_lbc_policy_attachment" {
  policy_arn = aws_iam_policy.sure_k8s_aws_lbc_policy.arn
  role       = aws_iam_role.sure_k8s_aws_lbc_role.name

  depends_on = [ aws_iam_role.sure_k8s_aws_lbc_role ]
}

# IAM role and SA association -- not through OIDC. 
# Pod Identity is a simpler method than IAM roles for service accounts, as this method doesn’t use OIDC identity providers. 
# Additionally, you can configure a role for Pod Identity once, and reuse it across clusters.
# resource "aws_eks_pod_identity_association" "sure_k8s_aws_lbc_oidc_sa_association" {
#   cluster_name    = aws_eks_cluster.surek8scluster.name
#   namespace       = "kube-system"
#   service_account = "aws-load-balancer-controller"
#   role_arn        = aws_iam_role.sure_k8s_aws_lbc_role.arn # ""

#   depends_on = [ aws_iam_role_policy_attachment.sure_k8s_aws_lbc_policy_attachment ]
# }

# # CMC are deprecated. This is AWS controller -- supports NLB, can use IPs in target groups
resource "helm_release" "sure_k8s_aws_lbc" {
  name = "sure-k8s-aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.surek8scluster.name
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = var.lbc_service_account_name # Should match with service_account in aws_eks_pod_identity_association
  }

  set {
    name  = "vpcId"
    value = aws_vpc.surek8svpc.id
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.sure_k8s_aws_lbc_role.arn
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "enableServiceMutatorWebhook"
    value = "false"
  }

  # depends_on = [helm_release.cluster_autoscaler]
}