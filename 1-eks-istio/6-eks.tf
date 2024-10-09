resource "aws_iam_role" "sure_k8s_cluster_role" {
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

resource "aws_iam_role_policy_attachment" "sure_k8s_cluster_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.sure_k8s_cluster_role.name
}

resource "aws_eks_cluster" "sure_k8s_cluster" {
  name     = "sure-k8s-cluster"
  role_arn = aws_iam_role.sure_k8s_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_us_east_1a.id,
      aws_subnet.private_us_east_1b.id,
      aws_subnet.public_us_east_1a.id,
      aws_subnet.public_us_east_1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.sure_k8s_cluster_role_policy]
}

output "sure_k8s_cluster_endpoint" {
  value = aws_eks_cluster.sure_k8s_cluster.endpoint
}
