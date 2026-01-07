variable "REGION" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "liorm-bluebricks-cluster" # Set your default
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "main-node-group"
}

variable "capacity_type" {
  description = "ON_DEMAND or SPOT"
  type        = string
  default     = "SPOT"
}

variable "instance_types" {
  description = "List of instance types"
  type        = list(string)
  default     = ["t3.small"]
}

variable "max_size" {
  type    = number
  default = 2
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "node_name" {
  type    = string
  default = "liorm-node"
}

# These variables are needed for the Secrets Manager lookups
variable "ACCOUNT" {
  description = "AWS account ID"
  type        = string
}

variable "SECRET" {
  description = "Name of the AWS credentials secret"
  type        = string
}
