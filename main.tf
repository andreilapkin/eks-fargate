provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.47"

  name                 = "${var.region}-eks-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b"]
  private_subnets      = ["10.0.0.0/18", "10.0.128.0/18"]
  public_subnets       = ["10.0.64.0/18", "10.0.192.0/18"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.region}-eks-${var.name}" = "shared"
    "kubernetes.io/role/elb"                              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.region}-eks-${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"                     = "1"
  }
}

module "eks" {
  source                               = "./eks"
  region                               = var.region
  vpc_id                               = module.vpc.vpc_id
  private_subnets                      = module.vpc.private_subnets
  public_subnets                       = module.vpc.public_subnets
  k8s_version                          = "1.20"
  name                                 = "web"
  kubeconfig_path                      = "~/.kube"
  eks_elb_ingress_controller_namespace = "ingress-nginx"
  eks_elb_ingress_controller_name      = "ingress-nginx"
  fargate_profiles = {
    system = {
      name = "system"
      selectors = [
        {
          namespace = "kube-system"
        },
        {
          namespace = "kubernetes-dashboard"
        },
        {
          namespace = "cattle-system"
        },
        {
          namespace = "ingress-nginx"
        },
        {
          namespace = "cert-manager"
        }
      ]
    }
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }
}