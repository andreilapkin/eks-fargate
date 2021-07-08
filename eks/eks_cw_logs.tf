resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.region}-eks-${var.name}/cluster"
  retention_in_days = 30

  tags = {
    Name = "${var.region}-eks-${var.name}-cw-log-group"
  }
}