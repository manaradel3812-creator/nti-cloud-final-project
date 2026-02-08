# resource "aws_lb" "nlb" {
#   name               = "${var.cluster_name}-nlb"
#   load_balancer_type = "network"
#   internal           = false
#   subnets            = data.aws_subnets.public.ids

#   tags = {
#     Environment = var.environment
#   }
# }

# resource "aws_lb_target_group" "app_tg" {
#   name        = "${var.cluster_name}-tg"
#   port        = var.target_group_port
#   protocol    = "TCP"
#   vpc_id      = data.aws_vpc.existing_vpc.id
#   target_type = "ip"

#   health_check {
#     protocol = "TCP"
#   }
# }

# resource "aws_lb_listener" "nlb_listener" {
#   load_balancer_arn = aws_lb.nlb.arn
#   port              = var.target_group_port
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }
