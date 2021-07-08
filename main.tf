module "us_east_1" {
  source             = "./region"
  global_vars        = local.global_vars
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.0.0/18", "10.0.128.0/18"]
  public_subnets     = ["10.0.64.0/18", "10.0.192.0/18"]
  region             = "us-east-1"
  k8s_version        = "1.20"
  name               = "web"
  kubeconfig_path    = "~/.kube"
  fargate_profiles = {
    system = {
      name = "system"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "kubernetes-dashboard"
        },
        {
          namespace = "cattle-system"
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