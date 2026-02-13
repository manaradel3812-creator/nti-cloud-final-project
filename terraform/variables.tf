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
# MongoDB Atlas Variables

variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas Public API Key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas Private API Key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "mongodb_region" {
  description = "MongoDB Atlas region"
  type        = string
  default     = "US_EAST_1"
}

variable "mongodb_instance_size" {
  description = "MongoDB instance size"
  type        = string
  default     = "M10"
}

variable "mongodb_min_instance_size" {
  description = "Minimum instance size for auto-scaling"
  type        = string
  default     = "M10"
}

variable "mongodb_max_instance_size" {
  description = "Maximum instance size for auto-scaling"
  type        = string
  default     = "M30"
}

variable "mongodb_disk_size_gb" {
  description = "Initial disk size in GB"
  type        = number
  default     = 10
}

variable "mongodb_username" {
  description = "MongoDB database username"
  type        = string
  default     = "manarapp"
}

variable "mongodb_password" {
  description = "MongoDB database password"
  type        = string
  sensitive   = true
}

variable "mongodb_database_name" {
  description = "MongoDB database name"
  type        = string
  default     = "manarapp"
}

variable "enable_private_endpoint" {
  description = "Enable AWS PrivateLink endpoint"
  type        = bool
  default     = false
}

variable "enable_vpc_peering" {
  description = "Enable VPC Peering with MongoDB Atlas"
  type        = bool
  default     = false
}

variable "mongodb_atlas_cidr" {
  description = "CIDR block for MongoDB Atlas"
  type        = string
  default     = "192.168.0.0/16"
}

variable "nat_gateway_ips" {
  description = "NAT Gateway IPs to whitelist"
  type        = list(string)
  default     = []
}
