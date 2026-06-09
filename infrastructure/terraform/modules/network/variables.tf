# Variáveis de entrada do módulo de rede.

variable "name_prefix" {
  type        = string
  description = "Prefix applied to all network resource names (e.g. microservices-dev)."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to spread subnets across. Must be at least as long as the subnet lists."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets (one per AZ)."
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the private subnets (one per AZ)."
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Provision a NAT gateway so private subnets get outbound internet. Off by default (NAT is not Free Tier)."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every network resource."
  default     = {}
}
