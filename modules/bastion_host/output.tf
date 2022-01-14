output "bastion_host_public_ip" {
  value = data.aws_instance.bastion_host_public_ip.public_ip
}
