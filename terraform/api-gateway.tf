##############################
# API Gateway
##############################

# HTTP API
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
  security_group_ids = [aws_security_group.lb_sg.id]  # reference existing SG
}

##############################
# Cognito Authorizer
##############################
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id          = aws_apigatewayv2_api.http_api.id
  authorizer_type = "JWT"
  name            = "cognito-jwt-authorizer"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    # تأكدي هنا ان resource Cognito عندك اسمه "main"
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
    audience = [aws_cognito_user_pool_client.main.id]
  }
}

##############################
# NLB Integration (Optional)
##############################
resource "aws_apigatewayv2_integration" "nlb_integration" {
  count            = var.nlb_arn != null ? 1 : 0
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = var.nlb_arn
  connection_type  = "VPC_LINK"
  connection_id    = aws_apigatewayv2_vpc_link.vpc_link.id
}

##############################
# API Gateway Route
##############################
resource "aws_apigatewayv2_route" "default" {
  count     = var.nlb_arn != null ? 1 : 0
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.nlb_integration[0].id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id

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
