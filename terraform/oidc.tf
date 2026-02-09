
##############################
# 1️⃣ TLS Certificate for OIDC
##############################
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

##############################
# 2️⃣ IAM OIDC Provider
##############################
resource "aws_iam_openid_connect_provider" "eks" {
  url            = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.oidc.certificates[0].sha1_fingerprint
  ]

  depends_on = [aws_eks_cluster.main]
}
