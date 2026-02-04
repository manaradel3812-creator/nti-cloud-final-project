# =====================================
# Data source for EKS Cluster
# =====================================
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.main.name
}

# =====================================
# IAM OIDC Provider
# =====================================
data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.main]
}

# =====================================
# EKS Cluster Auth
# =====================================
data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.main.name
}
