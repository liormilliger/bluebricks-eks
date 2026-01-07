################################################################################
# PROVIDERS & BACKEND
################################################################################
terraform {
  backend "s3" {
    bucket = "liorm-bluebricks"
    key    = "eks-bluebricks/terraform.tfstate"
    region = "us-east-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.REGION
}

################################################################################
# NETWORK DATA SOURCES (Dynamic Lookup)
################################################################################
# Fetch the specific VPC
data "aws_vpc" "selected" {
  id = "vpc-091e12d389402f660" 
}

# Automatically find Private Subnets in this VPC
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  # Assuming you tag your subnets. If not, we fetch all non-public or specific ones.
  # Adjust filter tags as per your environment, e.g., "Tier" = "Private"
  filter {
    name   = "tag:Name" 
    values = ["*private*"] # Adjust this filter based on your actual subnet names
  }
}

# Automatically find Public Subnets in this VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"] # Adjust this filter based on your actual subnet names
  }
}

################################################################################
# IAM Role for EKS Control Plane
################################################################################
resource "aws_iam_role" "eks-cluster-iam-role" {
  name = "${var.cluster_name}-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    provisioned_by = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-iam-role.name
}

################################################################################
# EKS Cluster
################################################################################
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster-iam-role.arn

  tags = {
    provisioned_by = "Terraform"
  }

  vpc_config {
    # Dynamically use the subnets found in the data source
    subnet_ids = concat(data.aws_subnets.private.ids, data.aws_subnets.public.ids)
    security_group_ids = [aws_security_group.eks_node_sg.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks-cluster-policy]
}

################################################################################
# OIDC Provider
################################################################################
data "tls_certificate" "eks_cluster_cert" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer

  tags = {
    Name = "oidc-provider-${replace(aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}"
  }
}
