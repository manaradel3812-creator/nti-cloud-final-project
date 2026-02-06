
vpc_name            = "prod-vpc"
environment         = "prod"
aws_region          = "us-east-1"
eks_cluster_name    = "prod-cluster"
cluster_name        = "prod-eks-cluster"
node_instance_types = ["t3.small"]
desired_capacity    = 3
min_size            = 2
max_size            = 5
nlb_arn             = null 
