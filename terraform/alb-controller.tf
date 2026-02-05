# # =====================================
# # ALB Controller (IRSA) Setup
# # =====================================

# data "aws_eks_cluster" "this" {
#   name = aws_eks_cluster.main.name
# }

# data "aws_eks_cluster_auth" "eks_auth" {
#   name = aws_eks_cluster.main.name
# }

# # IAM OIDC Provider for IRSA
# data "aws_iam_openid_connect_provider" "eks" {
#   url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
#   depends_on = [aws_eks_cluster.main]
# }

# # =====================================
# # ALB Controller Role (IRSA)
# # =====================================
# resource "aws_iam_role" "alb_controller_role" {
#   name = "${var.cluster_name}-alb-controller-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = data.aws_iam_openid_connect_provider.eks.arn
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#           }
#         }
#       }
#     ]
#   })
# }

# # =====================================
# # IAM Policy for ALB Controller
# # =====================================
# resource "aws_iam_policy" "alb_controller_policy" {
#   name   = "${var.cluster_name}-alb-controller-policy"
#   policy = file("${path.module}/iam/alb-policy.json")
# }

# # Attach the Policy to the Role
# resource "aws_iam_role_policy_attachment" "alb_attach" {
#   role       = aws_iam_role.alb_controller_role.name
#   policy_arn = aws_iam_policy.alb_controller_policy.arn
# }

# =====================================
# ALB Controller IAM Role (IRSA)
# =====================================

resource "aws_iam_role" "alb_controller_role" {
  name = "${var.cluster_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(
              aws_iam_openid_connect_provider.eks.url,
              "https://",
              ""
            )}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# =====================================
# ALB Controller IAM Policy
# =====================================

resource "aws_iam_policy" "alb_controller_policy" {
  name   = "${var.cluster_name}-alb-controller-policy"
  policy = file("${path.module}/iam/alb-policy.json")
}

# =====================================
# Attach Policy to Role
# =====================================

