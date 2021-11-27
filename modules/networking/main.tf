
// TODO break public and private into separate AZs
# data "aws_availability_zones" "available" {
#   state = "available"
# }

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  name                         = "${var.namespace}-vpc"
  cidr                         = "10.0.0.0/16"
  azs                          = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets               = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets              = ["10.0.10.0/24", "10.0.11.0/24"]
  create_database_subnet_group = true
  enable_nat_gateway           = true
  # 今回は、2つのNATゲートウェイを設置するため値はfalseにしておく。
  single_nat_gateway = false
  # アベイラビリティゾーンにつき1つのNATゲートウェイを設置する。
  one_nat_gateway_per_az = true
  # 以下2つの設定は、プライベートDNSに必要
  enable_dns_hostnames = true
  enable_dns_support   = true
}

// SG to allow SSH connections from anywhere
resource "aws_security_group" "allow_ssh_pub" {
  name        = "${var.namespace}-allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-allow_ssh_pub"
  }
}

// 0.0.0.0/0 を使用すると、すべての IPv4 アドレスが SSH/ を使用して、インスタンスにアクセスすることを許可されます。
// ::/0 を使用すると、すべての IPv6 アドレスからインスタンスにアクセスできるようになります。
// これはテスト環境で短時間なら許容できますが、実稼働環境で行うのは安全ではありません。
// 本番環境では、特定の IP アドレスまたは特定のアドレス範囲にのみ、インスタンスへのアクセスを限定します。
// https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/authorizing-access-to-an-instance.html

// SG to onlly allow SSH connections from VPC public subnets
resource "aws_security_group" "allow_http_and_https_priv" {
  name        = "${var.namespace}-allow_http_https_priv"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from internal VPC clients"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internal VPC clients"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-allow_http_and_https_priv"
  }
}

resource "aws_vpc" "mainvpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
