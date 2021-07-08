# Get variables from Global
variable "global_vars" {}
variable "region" {}
variable "name" {}
variable "k8s_version" {}
variable "fargate_profiles" {}
variable "kubeconfig_path" {}
variable "vpc_cidr" {}
data "aws_caller_identity" "current" {}
variable "availability_zones" {}
variable "private_subnets" {}
variable "public_subnets" {}