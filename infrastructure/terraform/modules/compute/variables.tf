# Variáveis de entrada do módulo de computação.

variable "name_prefix" {
  type        = string
  description = "Prefix applied to compute resource names (e.g. microservices-dev)."
}

variable "aws_region" {
  type        = string
  description = "Region the instance runs in, used to scope SSM/KMS ARNs."
}

variable "vpc_id" {
  type        = string
  description = "VPC the instance and its security group belong to."
}

variable "subnet_id" {
  type        = string
  description = "Subnet to launch the instance in (a public subnet for internet-facing app)."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI to use. Empty string selects the latest Amazon Linux 2023."
  default     = ""
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH. Empty string disables SSH key (use Session Manager instead)."
  default     = ""
}

variable "associate_public_ip" {
  type        = bool
  description = "Assign a public IP to the instance."
  default     = true
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB."
  default     = 10
}

variable "app_port" {
  type        = number
  description = "Application port exposed by the security group (API gateway)."
  default     = 8080
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to reach SSH (port 22). Empty string opens no SSH rule (Session Manager only)."
  default     = ""
}

variable "allowed_app_cidr" {
  type        = string
  description = "CIDR allowed to reach the application port."
  default     = "0.0.0.0/0"
}

variable "install_docker" {
  type        = bool
  description = "Install Docker + compose plugin via user_data on first boot."
  default     = true
}

variable "sqs_queue_arns" {
  type        = list(string)
  description = "Queue ARNs the instance may access. Empty list omits the SQS policy statement."
  default     = []
}

variable "ssm_path_prefix" {
  type        = string
  description = "SSM Parameter Store path prefix the instance may read (e.g. /microservices/dev)."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to compute resources."
  default     = {}
}
