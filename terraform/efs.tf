##################################
# 1️⃣ EFS File System
##################################
resource "aws_efs_file_system" "eks" {
  creation_token = "eks-efs"

  tags = {
    Name        = "${var.cluster_name}-efs"
    Environment = var.environment
  }
}

##################################
# 2️⃣ EFS Mount Targets
##################################
locals {
  new_subnets = [
    for s in aws_subnet.private : s.id
    if !(s.id in ["subnet-03c4b5116d58f774b","subnet-07ffc050eb159c896"])
  ]
}

resource "aws_efs_mount_target" "eks" {
  count = length(local.new_subnets)

  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = local.new_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}


##################################
# 3️⃣ Kubernetes StorageClass (EFS CSI)
##################################
resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "700"
  }

  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
}

# ==========================================
# Security Group for EFS
# ==========================================
resource "aws_security_group" "efs_sg" {
  name        = "${var.cluster_name}-efs-sg"
  description = "SG for EFS"
  vpc_id      = aws_vpc.main.id

  # السماح للـ EKS Nodes بالوصول على NFS
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
    description     = "Allow NFS from EKS Nodes"
  }

  # السماح بكل Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-efs-sg"
    Environment = var.environment
  }
}
