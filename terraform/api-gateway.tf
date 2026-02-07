resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.cluster_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.cluster_name}-vpc-link"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.lb_sg.id]
}

resource "aws_apigatewayv2_integration" "nlb_integration" {
  count           = var.nlb_arn != null ? 1 : 0
  api_id          = aws_apigatewayv2_api.http_api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = var.nlb_arn
  connection_type  = "VPC_LINK"
  connection_id    = aws_apigatewayv2_vpc_link.vpc_link.id
}

resource "aws_apigatewayv2_route" "default" {
  count     = var.nlb_arn != null ? 1 : 0
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.nlb_integration[0].id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id

  depends_on = [
    aws_apigatewayv2_authorizer.cognito
  ]
}




resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id          = aws_apigatewayv2_api.http_api.id
  authorizer_type = "JWT"
  name            = "cognito-jwt-authorizer"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
    audience = [aws_cognito_user_pool_client.this.id]
  }
}
