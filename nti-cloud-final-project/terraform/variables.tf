# ======================
# General
# ======================
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (nonprod or prod)"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name used for SGs, IAM roles, etc."
  type        = string
}

# ======================
# VPC
# ======================
variable "vpc_name" {
  description = "Name tag of the VPC to create"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones to use for subnets"
  type        = list(string)
}

# ======================
# EKS
# ======================
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

# ======================
# Optional NLB Settings
# ======================
variable "nlb_name" {
  description = "Optional NLB name"
  type        = string
  default     = ""
}

variable "nlb_arn" {
  description = "Optional NLB ARN for API Gateway integration"
  type        = string
  default     = null
}

variable "target_group_port" {
  description = "Port for the NLB Target Group"
  type        = number
  default     = 80
}
