resource "aws_security_group" "bastion_host_SG" {
  vpc_id = data.aws_vpc.vpc.id

  ingress {
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
    Name = "Security Group-LC"
  }
}

resource "aws_launch_configuration" "bastion_host_LC" {
  name_prefix       = "Bastion-Host-LC-"
  image_id          = data.aws_ami.latest_amazon_linux.id
  instance_type     = var.instance_type
  security_groups   = [aws_security_group.bastion_host_SG.id]
  enable_monitoring = var.monitoring
  key_name          = data.aws_key_pair.key.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion_host_ASG" {
  name                 = "ASG-${aws_launch_configuration.bastion_host_LC.name}"
  launch_configuration = aws_launch_configuration.bastion_host_LC.name
  vpc_zone_identifier  = data.aws_subnets.public_subnets.ids
  min_size             = 1
  max_size             = 1

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "Bastion Host-ASG"
    propagate_at_launch = true
  }
}
