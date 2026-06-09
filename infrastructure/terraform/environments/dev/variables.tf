# Variáveis do ambiente DEV. Os valores concretos estão em terraform.tfvars.

variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "eu-central-1"
}

variable "project" {
  type        = string
  description = "Project name, used in the name prefix and tags."
  default     = "microservices"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod), used in the name prefix and tags."
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Owner tag value."
  default     = "team-cn"
}

# --- Rede ---
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones for the subnets."
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ)."
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (one per AZ)."
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Provision a NAT gateway (not Free Tier)."
  default     = false
}

# --- Computação ---
variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH. Empty uses Session Manager only."
  default     = ""
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to reach SSH. Empty opens no SSH rule."
  default     = ""
}

variable "allowed_app_cidr" {
  type        = string
  description = "CIDR allowed to reach the application port."
  default     = "0.0.0.0/0"
}

# --- Base de dados ---
variable "db_instance_class" {
  type        = string
  description = "RDS instance class."
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  type        = string
  description = "PostgreSQL engine version."
  default     = "16"
}

variable "db_name" {
  type        = string
  description = "Initial database name."
  default     = "appdb"
}

variable "db_username" {
  type        = string
  description = "Database master username."
  default     = "appuser"
}

variable "db_multi_az" {
  type        = bool
  description = "Deploy RDS across two AZs."
  default     = false
}

variable "db_backup_retention" {
  type        = number
  description = "Days of automated RDS backups."
  default     = 1
}

variable "db_deletion_protection" {
  type        = bool
  description = "Protect the RDS instance from deletion."
  default     = false
}

variable "db_skip_final_snapshot" {
  type        = bool
  description = "Skip the final snapshot when the instance is destroyed."
  default     = true
}
