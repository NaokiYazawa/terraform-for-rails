output "ec2_public" {
  value = aws_instance.ec2_public
}

output "ec2_private01" {
  value = aws_instance.ec2_private01
}

output "ec2_private02" {
  value = aws_instance.ec2_private02
}

output "public_ip" {
  value = aws_instance.ec2_public.public_ip
}
