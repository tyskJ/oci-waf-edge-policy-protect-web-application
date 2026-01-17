/************************************************************
Record - A
************************************************************/
resource "aws_route53_record" "record_a_ec2" {
  zone_id = var.public_hostedzone_id
  name    = "origin.${var.domain_name}"
  type    = "A"
  ttl     = "10"
  records = [
    aws_eip.this.public_ip
  ]
}