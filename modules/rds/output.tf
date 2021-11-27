output "db_instance_endpoint" {
  value = module.db.db_instance_endpoint
}

output "role1" {
  value = aws_iam_role.role1
}
