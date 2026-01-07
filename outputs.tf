output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.eks-cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API server."
  value       = aws_eks_cluster.eks-cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "The base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster."
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.url
}

# -----------------------------------------------------------------------------
# Security Groups (CRITICAL for connecting to DBs/Caches)
# -----------------------------------------------------------------------------
output "node_security_group_id" {
  description = "Security Group ID of the worker nodes. Use this to allow access to RDS/ElastiCache."
  value       = aws_security_group.eks_node_sg.id
}

output "cluster_security_group_id" {
  description = "Security Group ID of the EKS Control Plane."
  value       = aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
}

# -----------------------------------------------------------------------------
# Cluster Identifiers
# -----------------------------------------------------------------------------
output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS Cluster."
  value       = aws_eks_cluster.eks-cluster.arn
}

output "cluster_id" {
  description = "The ID of the EKS Cluster."
  value       = aws_eks_cluster.eks-cluster.id
}