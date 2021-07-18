resource "kubernetes_service_account" "aws_lb_controller" {
  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
  }
  depends_on = [aws_eks_fargate_profile.main, local_file.kubeconfig]
}

resource "helm_release" "cert_manager" {
  name              = "cert-manager"
  repository        = "https://charts.jetstack.io"
  chart             = "cert-manager"
  namespace         = "cert-manager"
  create_namespace  = "true"
  force_update      = "true"
  dependency_update = "true"
  version           = "v1.4.0"

  set {
    name  = "webhook.securePort"
    value = "10260"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [aws_eks_fargate_profile.main, null_resource.coredns_patch, local_file.kubeconfig]
}

resource "helm_release" "aws_lb_controller" {
  name              = "aws-load-balancer-controller"
  repository        = "https://aws.github.io/eks-charts"
  chart             = "aws-load-balancer-controller"
  namespace         = "kube-system"
  force_update      = "true"
  dependency_update = "true"
  # version           = "2.2.1"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "replicaCount"
    value = "1"
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  depends_on = [aws_eks_fargate_profile.main, helm_release.cert_manager, local_file.kubeconfig]
}