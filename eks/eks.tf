data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.id
}


resource "aws_eks_cluster" "main" {
  name     = "${var.region}-eks-${var.name}"
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.k8s_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids = concat(tolist(var.public_subnets), tolist(var.private_subnets))
  }

  timeouts {
    delete = "30m"
  }

  depends_on = [
    aws_cloudwatch_log_group.eks_cluster,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}