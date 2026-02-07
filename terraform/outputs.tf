output "vpc_id" {
  value = data.aws_vpc.existing_vpc.id
}

output "private_subnet_ids" {
  value = data.aws_subnets.private.ids
}

output "public_subnet_ids" {
  value = data.aws_subnets.public.ids
}

# output "nlb_arn" {
#   value = aws_lb.nlb.arn
# }

# output "nlb_dns_name" {
#   value = aws_lb.nlb.dns_name
# }

# output "nlb_listener_arn" {
#   description = "ARN of the NLB listener for API Gateway"
#   value       = aws_lb_listener.nlb_listener.arn
# }

# output "target_group_arn" {
#   description = "ARN of the NLB target group"
#   value       = aws_lb_target_group.app_tg.arn
# }
