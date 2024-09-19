# To manage permissions for your applications that you deploy in Kubernetes. You can either attach policies to Kubernetes nodes directly. 
# In that case, every pod will get the same access to AWS resources. 
# Or you can create OpenID connect provider, 
# which will allow granting IAM permissions based on the service account used by the pod. File name is 8-iam-oidc.tf.
resource "aws_iam_role" "surek8snodesrole" {
  name = "sure-k8s-nodes-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "surek8snodesrole-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.surek8snodesrole.name
}

resource "aws_iam_role_policy_attachment" "surek8snodesrole-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.surek8snodesrole.name
}

resource "aws_iam_role_policy_attachment" "surek8snodesrole-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.surek8snodesrole.name
}

resource "aws_eks_node_group" "surek8sprivatenodes" {
  count = 1

  cluster_name    = aws_eks_cluster.surek8scluster.name
  node_group_name = "sure-k8s-private-nodes"
  node_role_arn   = aws_iam_role.surek8snodesrole.arn

  subnet_ids = [
    aws_subnet.private-us-east-1a.id
    # aws_subnet.private-us-east-1b.id
  ]

  capacity_type  = "SPOT"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.surek8snodesrole-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.surek8snodesrole-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.surek8snodesrole-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }
