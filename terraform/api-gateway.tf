##############################
# Data Source: البحث عن موازن الأحمال
##############################
# هذا الجزء يبحث في حساب AWS عن الـ NLB الذي ينشئه الـ EKS أوتوماتيكياً
# data "aws_lb" "eks_nlb" {
#   tags = {
#     "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
#     "service.k8s.aws/stack"                        = "default/hello-manar-service" # تاغ شائع يضعه الـ Controller
#   }
# }

##############################
# API Gateway (HTTP API)
##############################
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.eks_cluster_name}-http-api"
  protocol_type = "HTTP"
}

##############################
# VPC Link
##############################
resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.eks_cluster_name}-vpc-link"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.lb_sg.id]
}

##############################
# Cognito Authorizer
##############################
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.http_api.id
  authorizer_type  = "JWT"
  name             = "cognito-jwt-authorizer"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
    audience = [aws_cognito_user_pool_client.main.id]
  }
}

##############################
# NLB Integration (Dynamic)
##############################
resource "aws_apigatewayv2_integration" "nlb_integration" {
  # لن يتم الإنشاء إلا إذا وجد الـ Data Source موازن أحمال فعلي
  count = 0

  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "HTTP_PROXY"
  #integration_uri  = "http://${data.aws_lb.eks_nlb.dns_name}" # ربط ديناميكي بالـ DNS
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.vpc_link.id
  payload_format_version = "1.0"
}

##############################
# API Gateway Route
##############################
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id

  # ضيفي السطر ده للتأكيد (اختياري بس بيساعد في الـ Debugging)
  authorization_scopes = []

  target     = null
  depends_on = [aws_apigatewayv2_authorizer.cognito]
}

##############################
# API Gateway Stage
##############################
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}