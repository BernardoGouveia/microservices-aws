# Variáveis de entrada do módulo de base de dados.

variable "name_prefix" {
  type        = string
  description = "Prefix applied to database resource names (e.g. microservices-dev)."
}

variable "vpc_id" {
  type        = string
  description = "VPC the database security group belongs to."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group."
}

variable "app_security_group_id" {
  type        = string
  description = "Security group allowed to connect to the database (the application tier)."
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version."
  default     = "16"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class."
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Initial storage in GB."
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "Storage autoscaling ceiling in GB. Set equal to allocated_storage to disable."
  default     = 50
}

variable "db_name" {
  type        = string
  description = "Initial database name."
  default     = "appdb"
}

variable "username" {
  type        = string
  description = "Master username."
  default     = "appuser"
}

# Palavra-passe sensível: fornecida pelo ambiente (gerada com random_password),
# nunca escrita em código nem em ficheiros de variáveis.
variable "password" {
  type        = string
  description = "Master password (supplied by the caller, never hardcoded)."
  sensitive   = true
}

variable "port" {
  type        = number
  description = "Database port."
  default     = 5432
}

variable "multi_az" {
  type        = bool
  description = "Deploy the database across two AZs."
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Days of automated backups to keep."
  default     = 1
}

variable "deletion_protection" {
  type        = bool
  description = "Block accidental deletion of the instance."
  default     = false
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip the final snapshot on destroy (true is convenient for dev)."
  default     = true
}

variable "apply_immediately" {
  type        = bool
  description = "Apply modifications immediately instead of in the next maintenance window."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to database resources."
  default     = {}
}
