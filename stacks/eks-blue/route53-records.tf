resource "aws_route53_zone" "cluster_zone" {
  provider  = aws.default
  name      = local.cluster_domain
}

data "aws_route53_zone" "bizzabo_com" {
  provider = aws.default
  name     = "bizzabo.com."
}

resource "aws_route53_record" "cluster_domain_ns" {
  provider    = aws.default
  zone_id = data.aws_route53_zone.bizzabo_com.id
  name    = local.cluster_domain
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.cluster_zone.name_servers.0}",
    "${aws_route53_zone.cluster_zone.name_servers.1}",
    "${aws_route53_zone.cluster_zone.name_servers.2}",
    "${aws_route53_zone.cluster_zone.name_servers.3}",
  ]
}

resource "aws_route53_record" "cluster_default_cname" {
  provider = aws.default
  zone_id  = aws_route53_zone.cluster_zone.id
  name     = "*"
  type     = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = false
  }
}

