# Get variables from Global
variable "vpc_id" {}
variable "name" {}
variable "region" {}
variable "k8s_version" {}
variable "fargate_profiles" {}
variable "kubeconfig_path" {}
variable "private_subnets" {}
variable "public_subnets" {}
data "aws_caller_identity" "current" {}
variable "eks_elb_ingress_controller_namespace" {}
variable "eks_elb_ingress_controller_name" {}
