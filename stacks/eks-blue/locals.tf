locals {
  name                   = "bizzabo-green"
  cluster_domain         = "${local.name}.bizzabo.com"
  short_name             = "bizz"
  managed_by_tag         = "terraform/${local.name}"
  vpc_cidr               = "10.6.0.0/16"
  full_worker_name       = "${local.name}-eks-worker"
  vpc_availability_zones = ["us-east-1a", "us-east-1d", "us-east-1f"]

  additional_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
  }
  workers_additional_tags = {
    "k8s.io/cluster-autoscaler/enabled"       = "true"
    "k8s.io/cluster-autoscaler/${local.name}" = "owned"
  }
}
