# To manage permissions for your applications that you deploy in Kubernetes. You can either attach policies to Kubernetes nodes directly. 
# In that case, every pod will get the same access to AWS resources. 
# Or you can create OpenID connect provider, 
# which will allow granting IAM permissions based on the service account used by the pod. File name is 8-iam-oidc.tf.
resource "aws_iam_role" "sure_k8s_nodes_role" {
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

resource "aws_iam_role_policy_attachment" "sure_k8s_nodes_role_policy_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.sure_k8s_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "sure_k8s_nodes_role_policy_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.sure_k8s_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "sure_k8s_nodes_role_policy_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.sure_k8s_nodes_role.name
}

resource "aws_eks_node_group" "sure_k8s_nodes" {
  count = 1

  cluster_name    = aws_eks_cluster.sure_k8s_cluster.name
  node_group_name = "sure-k8s-private-nodes"
  node_role_arn   = aws_iam_role.sure_k8s_nodes_role.arn

  subnet_ids = [
    aws_subnet.private_us_east_1a.id
    # aws_subnet.private_us_east_1b.id
  ]

  capacity_type  = "SPOT"
  instance_types = ["t3.medium"]

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
    aws_iam_role_policy_attachment.sure_k8s_nodes_role_policy_worker_node,
    aws_iam_role_policy_attachment.sure_k8s_nodes_role_policy_cni,
    aws_iam_role_policy_attachment.sure_k8s_nodes_role_policy_registry,
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
