module "alb" {
  source  = "terraform-aws-modules/alb/aws"

  providers = {
    aws = aws.default
  }
  version = "~> 5.0"

  name = "${local.name}-ingress"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.vpc.default_security_group_id, aws_security_group.load_balancer.id]

  target_groups = [
    {
      name_prefix      = "${local.short_name}-"
      backend_protocol = "HTTP"
      backend_port     = 30000
      target_type      = "instance"
      health_check =  {
          enabled = true
          path = "/healthz"
      }

    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.aws_acm_certificate.star_bizzabo_com.arn
      target_group_index = 0
    }
  ]

  extra_ssl_certs = [{
    certificate_arn = aws_acm_certificate.cluster_certificate.arn
    https_listener_index = 0
  }]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    managed_by_tag = local.managed_by_tag
  }
}

resource "aws_security_group" "load_balancer" {
  provider = aws.default

  name        = "${local.name}-load-balancer"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
