# create an Amazon TLS/SSL certificate , public zone and validate the certificate using DNS method

# create the certificate using a wildcard for all the domains created in kiff-web.space
resource "aws_acm_certificate" "kiff-web" {
    domain_name = "*.kiff-web.space"
    validation_method = "DNS"
}

# calling the hosted zone created for the domain name
data "aws_route53_zone" "kiff-web" {
    name = "kiff-web.space"
    private_zone = false
}

# selecting a validation method
resource "aws_route53_record" "kiff-web" {
    for_each = {
        for dvo in aws_acm_certificate.kiff-web.domain_validation_options : dvo.domain_name => {
            name = dvo.resource_record_name
            record = dvo.resource_record_value
            type = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name = each.value.name
    records = [each.value.record]
    ttl = 60
    type = each.value.type
    zone_id = data.aws_route53_zone.kiff-web.zone_id
}

# validate the certificate through DNS method
resource "aws_acm_certificate_validation" "kiff-web" {
    certificate_arn = aws_acm_certificate.kiff-web.arn
    validation_record_fqdns = [for record in aws_route53_record.kiff-web : record.fqdn]
}

# create record for tooling 
resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.kiff-web.id
  name = "tooling.kiff-web.space"
  type = "A"

  alias {
    name = var.ext_alb_dns_name 
    zone_id = var.ext_alb_zone_id
    evaluate_target_health = true
  }
}

# create record for wordpress
resource "aws_route53_record" "wordpress" {
    name = "wordpress.kiff-web.space"
    zone_id = data.aws_route53_zone.kiff-web.zone_id
    type = "A"

    alias {
      name = var.ext_alb_dns_name
      zone_id = var.ext_alb_zone_id
      evaluate_target_health = true
    }
  
}