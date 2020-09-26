data "aws_eks_cluster" "cluster" {
  provider = aws.default
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  provider = aws.default
  name = module.eks_cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  providers = {
    aws = aws.default
  }

  cluster_name                         = local.name
  cluster_version                      = "1.17"
  subnets                              = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  vpc_id                               = module.vpc.vpc_id
  write_kubeconfig                     = false
  worker_additional_security_group_ids = [aws_security_group.load_balancer_vpc.id]
  worker_groups = [
    {
      instance_type = "c5.xlarge"
      asg_max_size  = 60
      ami_id        = "ami-0d9d22013d1f539ae"
      subnets       = module.vpc.public_subnets
    }
  ]
  tags      = local.workers_additional_tags
  map_users =  local.kube_admin_user
}

resource "aws_security_group" "load_balancer_vpc" {
  provider = aws.default

  name        = "${local.name}-load_balancer_vpc"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer.id]
  }
}
resource "aws_autoscaling_attachment" "attachment" {
  provider = aws.default
  autoscaling_group_name = module.eks_cluster.workers_asg_names[0]
  alb_target_group_arn   = module.alb.target_group_arns[0]
}

