#resource "aws_route53_zone" "main" {
#  name = var.site_domain
#}

#resource "aws_route53_record" "www" {
#  zone_id = aws_route53_zone.main.zone_id
#  name    = var.site_domain
#  type    = "A"
#
#  alias {
#    name                   = aws_cloudfront_distribution.cfd.domain_name
#    zone_id                = aws_cloudfront_distribution.cfd.hosted_zone_id
#    evaluate_target_health = false
#  }
#}
