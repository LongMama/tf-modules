data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_key_pair" "key" {
  filter {
    name   = "key-name"
    values = [var.key_name]
  }
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-VPC"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-public subnet-*"]
  }
}

data "aws_instance" "bastion_host_public_ip" {
  filter {
    name   = "tag:Name"
    values = ["Bastion Host-ASG"]
  }

  depends_on = [
    aws_launch_configuration.bastion_host_LC,
    aws_autoscaling_group.bastion_host_ASG
  ]
}
