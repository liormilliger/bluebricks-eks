resource "aws_security_group" "eks_node_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS cluster worker nodes"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}

# -----------------------------------------------------------------------------
# BREAK THE CYCLE: Standalone Rule
# -----------------------------------------------------------------------------
resource "aws_security_group_rule" "ingress_from_cluster" {
  description              = "Allow traffic from EKS control plane to worker nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
  
  depends_on = [ aws_eks_cluster.eks-cluster ]
}