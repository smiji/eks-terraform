

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

output "cluster_name" {
  value = module.eks.cluster_id
}

output "aws_region" {
  value = var.region
}
module "eks_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true


   aws_auth_users = [
    {
      userarn  = "arn:aws:iam::976193251196:user/tf_user_sj"
      username = "tf-user-sj"
      groups   = ["system:masters"]
    }
  ]
}
