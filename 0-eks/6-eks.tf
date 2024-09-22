resource "aws_iam_role" "surek8sclusterrole" {
  name = "sure-k8s-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "surek8sclusterrolepolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.surek8sclusterrole.name
}

resource "aws_eks_cluster" "surek8scluster" {
  name     = "sure-k8s-cluster"
  role_arn = aws_iam_role.surek8sclusterrole.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.surek8sclusterrolepolicy]
}

output "sure_k8s_cluster_endpoint" {
  value = aws_eks_cluster.surek8scluster.endpoint
}
