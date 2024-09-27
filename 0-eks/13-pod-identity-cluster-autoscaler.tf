# Create resource "aws_eks_addon" "sure_k8s_pod_identity" as prerequisite
resource "aws_iam_role" "sure_k8s_cluster_autoscaler_role" {
  name = "${aws_eks_cluster.surek8scluster.name}-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sure_k8s_cluster_autoscaler_policy" {
  name = "${aws_eks_cluster.surek8scluster.name}-cluster-autoscaler-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sure_k8s_cluster_autoscaler_attachment" {
  policy_arn = aws_iam_policy.sure_k8s_cluster_autoscaler_policy.arn
  role       = aws_iam_role.sure_k8s_cluster_autoscaler_role.name
}

resource "aws_eks_pod_identity_association" "sure_k8s_cluster_autoscaler_pod_identity_association" {
  cluster_name    = aws_eks_cluster.surek8scluster.name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.sure_k8s_cluster_autoscaler_role.arn
}

resource "helm_release" "sure_k8s_cluster_autoscaler" {
  name         = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0" # https://github.com/kubernetes/autoscaler, search 'cluster-autoscaler' in tags for latest version

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler" # Sames as in aws_eks_pod_identity_association
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.surek8scluster.name
  }

  # MUST be updated to match your region 
  set {
    name  = "awsRegion"
    value = "us-east-1"
  }

}