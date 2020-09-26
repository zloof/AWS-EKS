
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.default
  }
  name = local.name
  cidr = local.vpc_cidr

  azs             = local.vpc_availability_zones
  private_subnets = ["10.6.1.0/24", "10.6.2.0/24", "10.6.3.0/24"]
  public_subnets  = ["10.6.101.0/24", "10.6.102.0/24", "10.6.103.0/24"]

  enable_dns_hostnames = true

  tags = {
    managed_by_tag = local.managed_by_tag
  }
}
