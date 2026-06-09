# Variáveis de entrada do módulo de mensageria.

variable "name_prefix" {
  type        = string
  description = "Prefix applied to queue names (e.g. microservices-dev)."
}

variable "max_receive_count" {
  type        = number
  description = "Number of receives before a message is moved to the DLQ."
  default     = 5
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "Visibility timeout for the main queue."
  default     = 60
}

variable "retention_seconds" {
  type        = number
  description = "Message retention for the main queue (default 4 days)."
  default     = 345600
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "Long-polling wait time for the main queue."
  default     = 20
}

variable "dlq_retention_seconds" {
  type        = number
  description = "Message retention for the DLQ (default 14 days)."
  default     = 1209600
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to both queues."
  default     = {}
}
