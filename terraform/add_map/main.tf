
terraform {
  backend "s3" {
    bucket = "terraform-state-11"
    key    = "terraform/eks2-map"
    region = "eu-west-2"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
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
