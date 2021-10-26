output "vpc" {
  value = module.vpc
}

output "sg_pub_id" {
  value = aws_security_group.allow_ssh_pub.id
}

output "default_sg_id" {
  value = aws_default_security_group.default.id
}

# output "sg_priv_id" {
#   value = aws_security_group.allow_ssh_priv.id
# }
