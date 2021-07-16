variable "ingress_controller_version" {
  default = "0.46.0"
}

variable "ingress_controller_image" {
  default = "k8s.gcr.io/ingress-nginx/controller:v0.46.0@sha256:52f0058bed0a17ab0fb35628ba97e8d52b5d32299fbc03cc0f6c7b9ff036b61a"
}

resource "kubernetes_namespace" "ingress_controller" {
  metadata {
    name = var.eks_elb_ingress_controller_namespace
    labels = {
      "app.kubernetes.io/name"     = var.eks_elb_ingress_controller_name
      "app.kubernetes.io/instance" = var.eks_elb_ingress_controller_name
    }
  }
}

resource "kubernetes_service_account" "ingress_controller" {
  automount_service_account_token = true
  metadata {
    name      = var.eks_elb_ingress_controller_name
    namespace = var.eks_elb_ingress_controller_namespace
    labels = {
      "app.kubernetes.io/name"       = var.eks_elb_ingress_controller_name
      "app.kubernetes.io/instance"   = var.eks_elb_ingress_controller_name
      "app.kubernetes.io/version"    = var.ingress_controller_version
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/component"  = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_elb_ingress_controller.arn
    }
  }
}

data "template_file" "ingress_controller" {
  template = file("${path.module}/templates/ingress-nginx.tpl")
  vars = {
    iam_role     = aws_iam_role.eks_elb_ingress_controller.arn
    ingress_controller_namespace = var.eks_elb_ingress_controller_namespace
    ingress_controller_version = "0.46.0"
    ingress_controller_image = "k8s.gcr.io/ingress-nginx/controller:v0.46.0@sha256:52f0058bed0a17ab0fb35628ba97e8d52b5d32299fbc03cc0f6c7b9ff036b61a"
  }
}

resource "local_file" "ingress_controller" {
  filename = "${path.module}/manifests/ingress-nginx.yaml"
  content  = data.template_file.ingress_controller.rendered
  depends_on = [kubernetes_service_account.ingress_controller]
}

resource "null_resource" "ingress_controller" {
  provisioner "local-exec" {
    interpreter = ["/bin/zsh", "-c"]
    command     = <<EOF
kubectl --kubeconfig=<(echo '${data.template_file.kubeconfig.rendered}') apply -f ${path.module}/manifests/ingress-nginx.yaml
EOF
  }
  depends_on = [aws_eks_fargate_profile.main, data.template_file.kubeconfig, local_file.ingress_controller]
}