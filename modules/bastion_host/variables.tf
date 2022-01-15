variable "env" {
  default = ""
}

variable "instance_type" {
  description = "Instance type for Bastion Host"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key name for connetiong to an instance"
  default     = ""
}

variable "monitoring" {
  description = "Enables/disables detailed monitoring for Launch Configuration"
  default     = false
}
