resource "null_resource" "coredns_patch" {
  triggers = {
    fargate_profiles = aws_eks_fargate_profile.main["system"].arn
  }
  provisioner "local-exec" {
    interpreter = ["/bin/zsh", "-c"]
    command     = <<EOF
kubectl --kubeconfig=<(echo '${data.template_file.kubeconfig.rendered}') \
patch deployment coredns \
--namespace kube-system \
--type=json \
-p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
kubectl rollout restart -n kube-system deployment coredns
EOF
  }
  depends_on = [aws_eks_fargate_profile.main, data.template_file.kubeconfig]
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
  depends_on = [aws_eks_fargate_profile.main, null_resource.coredns_patch]
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
    name = "replicaCount"
    value = "1"
  }
  set {
    name = "region"
    value = var.region
  }
  set {
    name = "vpcId"
    value = "var.vpc_id"
  }
  depends_on = [aws_eks_fargate_profile.main, helm_release.cert_manager]
}