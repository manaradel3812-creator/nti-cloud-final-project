variable "vpc_name" {
  description = "Name tag of the existing VPC"
  type        = string
}
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (nonprod or prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}


variable "nlb_arn" {
  description = "The ARN of the Network Load Balancer"
  type        = string
  default     = null # ✅ يجعله اختيارياً فلا يفشل الـ Pipeline إذا لم يجد قيمة في tfvars
}