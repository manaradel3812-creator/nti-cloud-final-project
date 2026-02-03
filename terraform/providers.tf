terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "tfs3finalproject" # الاسم اللي اخترتيه
    key            = "dev/terraform.tfstate"  
    region         = "us-east-1"
    encrypt        = true                      
  }
}
provider "aws" {
  region     = "us-east-1"
  access_key = "A#"
  secret_key = "o#"
}
#provider "aws" {
 # region = "us-east-1"
#}


#data "aws_eks_cluster" "eks_cluster" {
 # name = var.eks_cluster_name
#}

#data "aws_eks_cluster_auth" "eks_auth" {
 # name = var.eks_cluster_name
#}


