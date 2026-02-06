# =====================================
# API Gateway HTTP API
# =====================================
resource "aws_apigatewayv2_api" "http_api" {
  name          = "eks-http-api"
  protocol_type = "HTTP"
}

# =====================================
# VPC Link (links API Gateway to the NLB)
# =====================================
resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.environment}-eks-vpc-link"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.lb_sg.id]
}

# =====================================
# NLB Integration
# =====================================

resource "aws_apigatewayv2_integration" "nlb_integration" {
  count           = var.nlb_arn != null ? 1 : 0
  api_id          = aws_apigatewayv2_api.http_api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = var.nlb_arn
  connection_type  = "VPC_LINK"
  connection_id    = aws_apigatewayv2_vpc_link.vpc_link.id
}

# =====================================
# Route
# =====================================
resource "aws_apigatewayv2_route" "default" {
  count     = var.nlb_arn != null ? 1 : 0
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.nlb_integration[0].id}"
}

# =====================================
# Stage
# =====================================
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"  # literal $default for HTTP API
  auto_deploy = true
}
