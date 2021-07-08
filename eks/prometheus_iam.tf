# resource "aws_iam_role" "eks_prometheus_ingest" {
#   name        = "${var.region}-eks-${var.name}-prometheus-ingest"
#   description = "Permissions required by the Prometheus"

#   force_detach_policies = true

#   assume_role_policy = <<ROLE
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:amp-iamproxy-ingest-service-account"
#         }
#       }
#     }
#   ]
# }
# ROLE
# }

# resource "aws_iam_policy" "AMPIngestPolicy" {
#   name   = "${var.region}-eks-${var.name}-AMPIngestPolicy"
#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#    "Statement": [
#        {"Effect": "Allow",
#         "Action": [
#            "aps:RemoteWrite", 
#            "aps:GetSeries", 
#            "aps:GetLabels",
#            "aps:GetMetricMetadata"
#         ], 
#         "Resource": "*"
#       }
#    ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "AMPIngestPolicy" {
#   policy_arn = aws_iam_policy.AMPIngestPolicy.arn
#   role       = aws_iam_role.eks_prometheus_ingest.name
# }

# resource "aws_iam_role" "eks_prometheus_query" {
#   name        = "${var.region}-eks-${var.name}-query-ingest"
#   description = "Permissions required by the Prometheus"

#   force_detach_policies = true

#   assume_role_policy = <<ROLE
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:amp-iamproxy-query-service-account"
#         }
#       }
#     }
#   ]
# }
# ROLE
# }

# resource "aws_iam_policy" "AMPQueryPolicy" {
#   name   = "${var.region}-eks-${var.name}-AMPQueryPolicy"
#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#    "Statement": [
#        {"Effect": "Allow",
#         "Action": [
#            "aps:QueryMetrics",
#            "aps:GetSeries", 
#            "aps:GetLabels",
#            "aps:GetMetricMetadata"
#         ], 
#         "Resource": "*"
#       }
#    ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "AMPQueryPolicy" {
#   policy_arn = aws_iam_policy.AMPQueryPolicy.arn
#   role       = aws_iam_role.eks_prometheus_ingest.name
# }