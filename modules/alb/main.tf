module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.namespace}-alb"

  load_balancer_type = "application"

  vpc_id          = var.vpc.vpc_id
  subnets         = [var.public_subnets[0], var.public_subnets[1]]
  security_groups = [var.default_sg.id, var.sg_priv.id]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "instance"
      targets = [
        {
          target_id = "${var.ec2_private01.id}"
          port      = 3000
        },
        {
          target_id = "${var.ec2_private02.id}"
          port      = 3000
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
      default_action = {
        type             = "forward"
        target_group_arn = module.alb.target_group_arns[0]
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

# resource "aws_acm_certificate" "cert" {
#   domain_name       = "www.farstep.tk"
#   validation_method = "DNS"
#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_route53_zone" "host_zone" {
  name = "farstep.tk"
}


# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   type            = each.value.type
#   ttl             = "300"

#   # レコードを追加するドメインのホストゾーンIDを指定
#   zone_id = aws_route53_zone.host_zone.zone_id
# }

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "www.farstep.tk"
  zone_id     = aws_route53_zone.host_zone.zone_id

  wait_for_validation = true
}

resource "aws_route53_record" "jump" {
  zone_id = aws_route53_zone.host_zone.zone_id
  name    = "jump.farstep.tk"
  type    = "A"
  ttl     = "300"
  records = [var.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.host_zone.zone_id
  name    = "www.farstep.tk"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_zone" "private" {
  name = "home"

  vpc {
    vpc_id     = var.vpc.vpc_id
    vpc_region = var.region
  }
}

resource "aws_route53_record" "jump_priv" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "jump.home"
  type    = "A"
  ttl     = "300"
  records = [var.ec2_public.private_ip]
}

resource "aws_route53_record" "web01_priv" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "web01.home"
  type    = "A"
  ttl     = "300"
  records = [var.ec2_private01.private_ip]
}

resource "aws_route53_record" "web02_priv" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "web02.home"
  type    = "A"
  ttl     = "300"
  records = [var.ec2_private02.private_ip]
}
