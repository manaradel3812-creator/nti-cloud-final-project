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

  # Disk Auto-Scaling
  disk_size_gb                 = var.mongodb_disk_size_gb
  auto_scaling_disk_gb_enabled = true

  # Compute Auto-Scaling
  auto_scaling_compute_enabled                    = true
  auto_scaling_compute_scale_down_enabled         = true
  provider_auto_scaling_compute_min_instance_size = var.mongodb_min_instance_size
  provider_auto_scaling_compute_max_instance_size = var.mongodb_max_instance_size

  # Cloud Backup (enabled for prod only)
  cloud_backup = var.environment == "prod" ? true : false
  
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

# Network Access - Allow EKS VPC CIDR
resource "mongodbatlas_project_ip_access_list" "eks_vpc" {
  project_id = mongodbatlas_project.main.id
  cidr_block = aws_vpc.main.cidr_block
  comment    = "EKS VPC CIDR - ${var.environment}"
}

# Optional: Allow NAT Gateway IPs
resource "mongodbatlas_project_ip_access_list" "nat_gateway" {
  count = length(var.nat_gateway_ips)
  
  project_id = mongodbatlas_project.main.id
  ip_address = var.nat_gateway_ips[count.index]
  comment    = "NAT Gateway ${count.index + 1} - ${var.environment}"
}

# Optional: Private Endpoint (for prod)
resource "mongodbatlas_privatelink_endpoint" "main" {
  count = var.enable_private_endpoint ? 1 : 0

  project_id    = mongodbatlas_project.main.id
  provider_name = "AWS"
  region        = var.aws_region
}

# Optional: VPC Peering (for prod)
resource "mongodbatlas_network_container" "main" {
  count = var.enable_vpc_peering ? 1 : 0

  project_id       = mongodbatlas_project.main.id
  atlas_cidr_block = var.mongodb_atlas_cidr
  provider_name    = "AWS"
  region_name      = var.mongodb_region
}

resource "mongodbatlas_network_peering" "main" {
  count = var.enable_vpc_peering ? 1 : 0

  accepter_region_name   = var.aws_region
  project_id             = mongodbatlas_project.main.id
  container_id           = mongodbatlas_network_container.main[0].container_id
  provider_name          = "AWS"
  route_table_cidr_block = aws_vpc.main.cidr_block
  vpc_id                 = aws_vpc.main.id
  aws_account_id         = data.aws_caller_identity.current.account_id
}
