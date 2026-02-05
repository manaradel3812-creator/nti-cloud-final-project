
resource "aws_iam_openid_connect_provider" "eks" {
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd2e5e7"]
}

# # =====================================
# # OIDC Provider for EKS (IRSA)
# # =====================================

# data "aws_eks_cluster" "cluster" {
#   name = aws_eks_cluster.main.name
# }

# data "tls_certificate" "oidc" {
#   url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [
#     data.tls_certificate.oidc.certificates[0].sha1_fingerprint
#   ]
# }
