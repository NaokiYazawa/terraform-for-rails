output "public_ip" {
  value = aws_instance.ec2_public.public_ip
}

output "private_ip01" {
  value = aws_instance.ec2_private01.private_ip
}

output "private_ip02" {
  value = aws_instance.ec2_private02.private_ip
}