variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(any)
  default = {
    Enviroment = ""
  }
}

variable "vpc_cidr" {
  default = ""
}

variable "public_subnet_cidrs" {
  description = "Cidr blocks for Public subnet"
  type        = list(any)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "Cidr blocks for Private subnet"
  type        = list(any)
  default     = []
}

variable "database_subnet_cidrs" {
  description = "Cidr blocks for Database subnet"
  type        = list(any)
  default     = []
}
