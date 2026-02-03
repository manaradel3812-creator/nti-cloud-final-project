# 1. إنشاء الـ EKS Cluster Control Plane
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # هنا Terraform بيستخدم الـ Data Source اللي عملناه عشان يجيب الـ Private Subnets
    subnet_ids = data.aws_subnets.private.ids
    
    # للأمان، بنخلي الوصول للـ API بتاع الـ Cluster خاص وعام معاً
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy
  ]
}

# 2. إنشاء الـ Node Group (الأجهزة اللي هتشغل الـ Containers)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "managed-nodes"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  
  # الـ Nodes لازم تكون في الـ Private Subnets
  subnet_ids      = data.aws_subnets.private.ids

  scaling_config {
    desired_size = 2 # هيبدأ بـ 2 Nodes
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = ["t3.small"] # حجم مناسب جداً للـ Testing والـ Argo CD

  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly,
  ]
}
# Fargate Profile
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn  # <- هنا غير الدور
  subnet_ids             = data.aws_subnets.private.ids

  selector {
    namespace = "default"
  }

  depends_on = [aws_eks_cluster.main]
}

