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

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

resource "aws_route53_zone" "host_zone" {
  name = "farstep.tk"
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
