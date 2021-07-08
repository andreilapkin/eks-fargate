locals {
  fargate_profiles_expanded = { for k, v in var.fargate_profiles : k => v }
}

resource "random_id" "fargate_profile" {
  for_each               = local.fargate_profiles_expanded
  byte_length = 2
}

resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  for_each               = local.fargate_profiles_expanded
  fargate_profile_name   = "${var.region}-eks-${var.name}-${each.key}-${random_id.fargate_profile[each.key].hex}"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = data.aws_subnet_ids.private_subnets.ids

  dynamic "selector" {
    for_each = each.value.selectors
    content {
      namespace = selector.value["namespace"]
      labels    = lookup(selector.value, "labels", {})
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    create = "30m"
    delete = "60m"
  }
}