resource "aws_apigatewayv2_api" "http_api" {
  name          = "eks-http-api"
  protocol_type = "HTTP"
}
# VPC Link (يربط API Gateway بالـ ALB)
resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.environment}-eks-vpc-link"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.lb_sg.id]
}
#Integration (API → ALB)
data "aws_lb" "eks_alb" {
  name = "k8s-default-hello" # هتغيريه بعد ما الـ Ingress يطلع
}

resource "aws_apigatewayv2_integration" "alb_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = data.aws_lb.eks_alb.arn

  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.vpc_link.id
}
#Route
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

#stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
