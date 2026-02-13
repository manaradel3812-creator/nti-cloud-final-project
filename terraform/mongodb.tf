# MongoDB Atlas Project
resource "mongodbatlas_project" "main" {
  name   = "${var.environment}-manar-project"
  org_id = var.mongodb_atlas_org_id

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "manar-app"
  }
}

# MongoDB Atlas Cluster
resource "mongodbatlas_cluster" "main" {
  project_id   = mongodbatlas_project.main.id
  name         = "${var.environment}-manar-cluster"
  cluster_type = "REPLICASET"

  # Provider Settings
  provider_name               = "AWS"
  provider_region_name        = var.mongodb_region
  provider_instance_size_name = var.mongodb_instance_size

  # Disk
  disk_size_gb = var.mongodb_disk_size_gb
  auto_scaling_disk_gb_enabled = true

  # Compute Auto-Scaling
  auto_scaling_compute_enabled                    = true
  auto_scaling_compute_scale_down_enabled        = true
  provider_auto_scaling_compute_min_instance_size = var.mongodb_min_instance_size
  provider_auto_scaling_compute_max_instance_size = var.mongodb_max_instance_size

  # Backup
  pit_enabled                   = var.environment == "prod" ? true : false
  backup_enabled                = var.environment == "prod" ? true : false
  cloud_backup                  = var.environment == "prod" ? true : false
  
  # MongoDB Version
  mongo_db_major_version = "7.0"

  tags {
    key   = "Environment"
    value = var.environment
  }
}

# Database User
resource "mongodbatlas_database_user" "main" {
  username           = var.mongodb_username
  password           = var.mongodb_password
  project_id         = mongodbatlas_project.main.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.mongodb_database_name
  }

  labels {
    key   = "Environment"
    value = var.environment
  }

  scopes {
    name = mongodbatlas_cluster.main.name
    type = "CLUSTER"
  }
}

# Network Access - Allow EKS Cluster
resource "mongodbatlas_project_ip_access_list" "eks_nodes" {
  project_id = mongodbatlas_project.main.id
  
  # Allow all IPs in VPC CIDR
  cidr_block = aws_vpc.main.cidr_block
  comment    = "EKS Cluster CIDR - ${var.environment}"
}

# Optional: Allow specific IPs (like NAT Gateway)
resource "mongodbatlas_project_ip_access_list" "nat_gateway" {
  count = length(var.nat_gateway_ips) > 0 ? length(var.nat_gateway_ips) : 0
  
  project_id = mongodbatlas_project.main.id
  ip_address = var.nat_gateway_ips[count.index]
  comment    = "NAT Gateway ${count.index + 1} - ${var.environment}"
}
