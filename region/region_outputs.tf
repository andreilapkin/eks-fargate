data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    kubeconfig_name     = "eks_${aws_eks_cluster.main.name}"
    clustername         = aws_eks_cluster.main.name
    endpoint            = data.aws_eks_cluster.cluster.endpoint
    cluster_auth_base64 = data.aws_eks_cluster.cluster.certificate_authority[0].data
  }
}

resource "local_file" "kubeconfig" {
  content         = data.template_file.kubeconfig.rendered
  filename        = pathexpand("${var.kubeconfig_path}/config")
  file_permission = "0600"
}

output "kubectl_config" {
  description = "Path to new kubectl config file"
  value       = pathexpand("${var.kubeconfig_path}/config")
}

output "cluster_id" {
  description = "ID of the created cluster"
  value       = aws_eks_cluster.main.id
}
