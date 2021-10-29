module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "ssh-key" {
  source    = "./modules/ssh-key"
  namespace = var.namespace
}

module "ec2" {
  source        = "./modules/ec2"
  namespace     = var.namespace
  vpc           = module.networking.vpc
  sg_pub_id     = module.networking.sg_pub_id
  default_sg_id = module.networking.default_sg_id
  # sg_priv_id = module.networking.sg_priv_id
  key_name = module.ssh-key.key_name
}

module "alb" {
  source         = "./modules/alb"
  namespace      = var.namespace
  vpc            = module.networking.vpc
  public_subnets = module.networking.public_subnets
  default_sg     = module.networking.default_sg
  sg_priv        = module.networking.sg_priv
  ec2_private01  = module.ec2.ec2_private01
  ec2_private02  = module.ec2.ec2_private02
  public_ip      = module.ec2.public_ip
}
