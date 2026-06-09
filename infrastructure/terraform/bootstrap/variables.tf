# Variáveis do bootstrap do estado remoto.

variable "aws_region" {
  type        = string
  description = "Region to create the state bucket and lock table in. Must match the backend region of the environments."
  default     = "eu-central-1"
}

variable "project" {
  type        = string
  description = "Project tag value."
  default     = "microservices"
}

variable "owner" {
  type        = string
  description = "Owner tag value."
  default     = "team-cn"
}

# Deve coincidir com o "bucket" no backend.tf de cada ambiente.
variable "state_bucket_name" {
  type        = string
  description = "Globally-unique S3 bucket name for Terraform state. Must match the bucket in each environment's backend.tf."
  default     = "microservices-tfstate-054862141870"
}

# Deve coincidir com o "dynamodb_table" no backend.tf de cada ambiente.
variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for state locking. Must match dynamodb_table in each environment's backend.tf."
  default     = "microservices-tf-locks"
}

# Email do alarme de billing. Sem default de proposito: passa via -var para nao
# ficar gravado no repo (publico).
variable "billing_alarm_email" {
  type        = string
  description = "Email que recebe os alertas de billing (passar via -var)."
}

variable "billing_alarm_threshold_usd" {
  type        = number
  description = "Limite de custo estimado (USD) que dispara o alarme de billing."
  default     = 5
}
