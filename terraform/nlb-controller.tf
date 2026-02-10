# ##################################
# # Network Load Balancer
# ##################################
# resource "aws_lb" "nlb" {
#   name               = "${var.cluster_name}-nlb"
#   load_balancer_type = "network"
#   internal           = false

#   subnets = aws_subnet.public[*].id

#   enable_cross_zone_load_balancing = true

#   tags = {
#     Name        = "${var.cluster_name}-nlb"
#     Environment = var.environment
#   }
# }

# ##################################
# # Target Group
# ##################################
# resource "aws_lb_target_group" "app_tg" {
#   name        = "${var.cluster_name}-tg"
#   port        = var.target_group_port
#   protocol    = "TCP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"

#   health_check {
#     protocol = "TCP"
#     port     = var.target_group_port
#   }

#   depends_on = [aws_lb.nlb]
# }

# ##################################
# # Listener
# ##################################
# resource "aws_lb_listener" "nlb_listener" {
#   load_balancer_arn = aws_lb.nlb.arn
#   port              = var.target_group_port
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }
