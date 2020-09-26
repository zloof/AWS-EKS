data "aws_acm_certificate" "star_bizzabo_com" {
  provider    = aws.default
  domain      = "*.bizzabo.com"
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_acm_certificate" "cluster_certificate" {
  provider                  = aws.default
  domain_name               = local.cluster_domain
  subject_alternative_names = ["*.${local.cluster_domain}"]
  validation_method         = "DNS"

  tags = {
    "kubernetes.io/cluster/${local.name}" = "owned"
    "ManagedBy"                           = local.managed_by_tag
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cluster_certificate_validation" {
  provider = aws.default
  name     = aws_acm_certificate.cluster_certificate.domain_validation_options[0].resource_record_name
  type     = aws_acm_certificate.cluster_certificate.domain_validation_options[0].resource_record_type
  zone_id  = aws_route53_zone.cluster_zone.id
  records = [aws_acm_certificate.cluster_certificate.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cluster_certificate" {
  provider        = aws.default
  certificate_arn = aws_acm_certificate.cluster_certificate.arn

  validation_record_fqdns = [
    aws_route53_record.cluster_certificate_validation.fqdn
  ]
}
