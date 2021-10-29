output "vpc" {
  value = module.vpc
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "sg_pub_id" {
  value = aws_security_group.allow_ssh_pub.id
}

output "default_sg_id" {
  value = aws_default_security_group.default.id
}

output "default_sg" {
  value = aws_default_security_group.default
}

output "sg_priv" {
  value = aws_security_group.allow_ssh_priv
}
