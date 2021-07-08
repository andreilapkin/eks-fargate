resource "aws_ec2_tag" "vpc_tag" {
  resource_id = aws_vpc.main.id
  key         = "kubernetes.io/cluster/${var.region}-eks-${var.name}"
  value       = "shared"
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = aws_vpc.main.id
  filter {
    name   = "tag:public"
    values = ["false"]
  }
}

resource "aws_ec2_tag" "private_subnet_tag" {
  for_each    = data.aws_subnet_ids.private_subnets.ids
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  for_each    = data.aws_subnet_ids.private_subnets.ids
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.region}-eks-${var.name}"
  value       = "shared"
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = aws_vpc.main.id
  filter {
    name   = "tag:public"
    values = ["true"]
  }
}

resource "aws_ec2_tag" "public_subnet_tag" {
  for_each    = data.aws_subnet_ids.public_subnets.ids
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_cluster_tag" {
  for_each    = data.aws_subnet_ids.public_subnets.ids
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.region}-eks-${var.name}"
  value       = "shared"
}