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

resource "null_resource" "default_namespace_zero_limit" {
  provisioner "local-exec" {
    interpreter = ["/bin/zsh", "-c"]
    command     = <<EOF
kubectl --kubeconfig=<(echo '${data.template_file.kubeconfig.rendered}') \
apply -f kube/zero-limit-range.yaml --namespace=default
EOF
  }
  depends_on = [aws_eks_fargate_profile.main, data.template_file.kubeconfig]
}