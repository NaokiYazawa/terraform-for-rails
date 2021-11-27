module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "sample-db"

  engine            = "mysql"
  engine_version    = "8.0.23"
  instance_class    = "db.t2.micro"
  allocated_storage = 20

  name     = "sample_db"
  username = "root"
  password = "password"
  port     = "3306"

  vpc_security_group_ids = [var.default_sg.id]

  backup_retention_period = 7
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = true

  # DB subnet group
  subnet_ids = [var.private_subnets[0], var.private_subnets[1]]

  # The Availability Zone of the RDS instance
  availability_zone = "ap-northeast-1a"

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_connection"
      value = "utf8mb4"
    },
    {
      name  = "character_set_database"
      value = "utf8mb4"
    },
    {
      name  = "character_set_results"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name         = "skip-character-set-client-handshake"
      value        = "1"
      apply_method = "pending-reboot"
    },
  ]

  options = [
  ]
}

resource "aws_s3_bucket" "s3b" {
  bucket        = "recipegram-bucket"
  acl           = "private"
  force_destroy = true
}


# resource "aws_iam_role" "role_for_s3" {
#   name               = "role_for_s3"
#   assume_role_policy = <<EOF
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Sid": "",
#           "Effect": "Allow",
#           "Principal": {
#             "Service": "s3.amazonaws.com"
#           },
#           "Action": "sts:AssumeRole"
#         }
#       ]
#     }
#   EOF
# }


# resource "aws_iam_role_policy" "iam_role_policy" {
#   name   = "iam_role_policy"
#   role   = aws_iam_role.role_for_s3.id
#   policy = <<EOF
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Sid": "",
#           "Effect": "Allow",
#           "Action": [
#             "s3:*"
#           ],
#           "Resource": "*"
#         }
#       ]
#     }
#   EOF
# }


data "aws_iam_policy_document" "policy1" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "policy1" {
  name        = "policy1"
  path        = "/"
  description = ""
  policy      = data.aws_iam_policy_document.policy1.json
}

# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
data "aws_iam_policy_document" "role1_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role1" {
  name               = "role1"
  assume_role_policy = data.aws_iam_policy_document.role1_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "role1_attachement" {
  role       = aws_iam_role.role1.name
  policy_arn = aws_iam_policy.policy1.arn
}
