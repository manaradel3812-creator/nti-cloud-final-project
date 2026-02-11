# ##################################
# # 0️⃣ Data Sources
# ##################################
# data "aws_eks_cluster" "cluster" {
#   name = var.eks_cluster_name
# }

##################################
# 1️⃣ Kubernetes Provider (EXEC)
##################################
provider "kubernetes" {
  host = aws_eks_cluster.main.endpoint

  cluster_ca_certificate = base64decode(
    aws_eks_cluster.main.certificate_authority[0].data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.main.name
    ]
  }
}


##################################
# 2️⃣ EKS Cluster
##################################
resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy
  ]
}

##################################
# 3️⃣ EFS CSI Addon
##################################
resource "aws_eks_addon" "efs_csi" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-efs-csi-driver"
  service_account_role_arn = aws_iam_role.efs_csi_driver.arn

  depends_on = [aws_eks_cluster.main]
}

##################################
# 4️⃣ Node Group
##################################
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "managed-nodes"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND"

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly
  ]
}

##################################
# 5️⃣ Fargate Profiles
##################################
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids             = aws_subnet.private[*].id

  selector { namespace = "default" }
  selector { namespace = "kube-system" }
  selector { namespace = "ingress-nginx" }
  selector { namespace = "argocd" }
  selector { namespace = "external-secrets" }

  depends_on = [aws_eks_cluster.main]
}

# resource "aws_eks_fargate_profile" "devops_tools" {
#   cluster_name           = aws_eks_cluster.main.name
#   fargate_profile_name   = "devops-tools"
#   pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
#   subnet_ids             = aws_subnet.private[*].id

#   # selector { namespace = "sonarqube" }
#   # selector { namespace = "nexus" }

#   depends_on = [aws_eks_cluster.main]
# }

##################################
# 6️⃣ Node Group خاص بـ Stateful Workloads (SonarQube & Nexus)
##################################
# resource "aws_eks_node_group" "stateful" {
#   cluster_name    = aws_eks_cluster.main.name
#   node_group_name = "stateful-nodes"
#   node_role_arn   = aws_iam_role.eks_nodes_role.arn  # نفس role الـ main node group
#   subnet_ids      = aws_subnet.private[*].id

#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }

#   instance_types = ["t3.micro"]  # أو t3.medium حسب الموارد المطلوبة
#   capacity_type  = "ON_DEMAND"

#   # Label علشان نحدد الـ pods اللي تتشغل هنا
#   labels = {
#     workload = "stateful"
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.nodes_AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly
#   ]
# }


