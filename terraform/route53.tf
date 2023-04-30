data "aws_route53_zone" "nkuproject_zone" {
  name = "<Custom Domain>"
}

resource "aws_route53_record" "movies-edge-api" {
  zone_id = data.aws_route53_zone.nkuproject_zone.zone_id
  name    = "<Custom Edge Domain>"
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.movies_cloudfront.domain_name]
}

resource "aws_route53_record" "movies-source-api" {
  zone_id = data.aws_route53_zone.nkuproject_zone.zone_id
  name    = "<Custom Source Domain>"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.movies_load_balancer.dns_name]
}

resource "aws_route53_record" "movies-instance" {
  zone_id = data.aws_route53_zone.nkuproject_zone.zone_id
  name    = "<EC2 Instance Domain>"
  type    = "A"
  ttl     = 300
  records = [aws_eip.movies_instance_eip.public_ip]
}