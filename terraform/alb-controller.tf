data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.main.name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = var.eks_cluster_name
}
