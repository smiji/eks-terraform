

#EKS Cluster 
provider "aws" {
  region = var.region
}
terraform {
  backend "s3" {
    bucket = "terraform-state-11"
    key    = "terraform/eks2"
    region = "eu-west-2"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = "eks-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b"]
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway   = true
  tags = {
    Name = "eks-vpc"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.28.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  subnet_ids         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true
  access_entries = {
    # One access entry with a policy associated
    user_access = {
      principal_arn     = "arn:aws:iam::976193251196:user/terraform-deploy"

      policy_associations = {
        user_access = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default","kube-system"]
            type       = "namespace"
          }
        }
      }
    }
  }
    eks_managed_node_groups = {
    eks_node = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }
  
}


output "aws_region" {
  value = var.region
}
