# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

# Generates a local file with the given content.
resource "local_file" "private_key" {
  filename = "${var.namespace}-key.pem"
  // The content of file to create. Will not be displayed in diffs.
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0400"
}

# Provides an EC2 key pair resource. A key pair is used to control login access to EC2 instances.
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.namespace}-key"
  public_key = tls_private_key.key.public_key_openssh
}
