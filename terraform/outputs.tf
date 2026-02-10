output "vpc_id" { value = aws_vpc.main.id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }

output "eks_cluster_name" { value = aws_eks_cluster.main.name }
output "eks_cluster_endpoint" { value = aws_eks_cluster.main.endpoint }
output "eks_cluster_arn" { value = aws_eks_cluster.main.arn }

output "eks_node_group_name" { value = aws_eks_node_group.main.node_group_name }
output "fargate_profile_name" { value = aws_eks_fargate_profile.default.fargate_profile_name }

output "cognito_user_pool_id" { value = aws_cognito_user_pool.main.id }
output "cognito_user_pool_client_id" { value = aws_cognito_user_pool_client.main.id }
output "cognito_user_pool_domain" { value = aws_cognito_user_pool_domain.main.domain }

# 👇 الأجزاء اللي كانت ناقصة ومهمة للـ Pipeline

output "lbc_iam_role_arn" {
  value       = try(aws_iam_role.lbc_irsa.arn, null)
  description = "IAM Role ARN for AWS Load Balancer Controller"
}
