variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}

variable "public_ip" {
  type = any
}

variable "public_subnets" {
  type = any
}

variable "default_sg" {
  type = any
}

variable "sg_priv" {
  type = any
}

variable "ec2_public" {
  type = any
}

variable "ec2_private01" {
  type = any
}

variable "ec2_private02" {
  type = any
}

variable "region" {
  type = string
}

variable "db_instance_endpoint" {
  type = string
}
