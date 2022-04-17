resource "aws_acm_certificate" "main_cert" {
  provider          = aws.us-east-1
  #  domain_name               = aws_route53_zone.main.name
  domain_name       = var.site_domain
  #  subject_alternative_names = ["www.${aws_route53_zone.main.name}"]
  validation_method = "DNS"
  tags              = {}
}

#resource "aws_route53_record" "main_cnames" {
#  for_each = {
#    for dvo in aws_acm_certificate.main_cert.domain_validation_options : dvo.domain_name => {
#      name   = dvo.resource_record_name
#      record = dvo.resource_record_value
#      type   = dvo.resource_record_type
#    }
#  }
#  zone_id = aws_route53_zone.main.zone_id
#  name    = each.value.name
#  records = [each.value.record]
#  type    = each.value.type
#  ttl     = 60
#}

#resource "aws_acm_certificate_validation" "main_cert_validation" {
#  provider                = aws.us-east-1
#  certificate_arn         = aws_acm_certificate.main_cert.arn
#  validation_record_fqdns = [for record in aws_route53_record.main_cnames : record.fqdn]
#}
