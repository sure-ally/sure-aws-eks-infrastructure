# This is mostly for autoscaler in cluser, useful to scale up the nodes based on pods scheduling
data "aws_iam_policy_document" "surek8sclusterautoscalerassumerolepolicy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.surek8soidcprovider.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.surek8soidcprovider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

  }
}

resource "aws_iam_role" "surek8sclusterautoscalerrole" {
  assume_role_policy = data.aws_iam_policy_document.surek8sclusterautoscalerassumerolepolicy.json
  name               = "sure-k8s-cluster-autoscaler-role"
}

resource "aws_iam_policy" "surek8sclusterautoscalerpolicy" {
  name = "sure-k8s-cluster-autoscaler-policy"

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeAutoScalingGroups",
          "ec2:DescribeLaunchTemplateVersions",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeLaunchConfigurations",
          "ec2:DescribeInstanceTypes",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
        ]
        Effect = "Allow"
        Resource = "*"
        Condition = {
          "StringEquals" = {
            "aws:ResourceTag/k8s.io/cluster-autoscaler/sure-k8s-cluster": "owned"
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "surek8sclusterautoscalerattach" {
  role       = aws_iam_role.surek8sclusterautoscalerrole.name
  policy_arn = aws_iam_policy.surek8sclusterautoscalerpolicy.arn
}

output "sure_k8s_cluster_autoscaler_arn" {
  value = aws_iam_role.surek8sclusterautoscalerrole.arn
}