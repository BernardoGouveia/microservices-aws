# Saídas do ambiente PROD (consultar com: terraform output).

output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "ec2_public_ip" {
  description = "Public IP of the application EC2 instance (use for Ansible inventory / browsing)."
  value       = module.compute.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the application EC2 instance."
  value       = module.compute.public_dns
}

output "ec2_instance_id" {
  description = "EC2 instance ID (use with: aws ssm start-session --target <id>)."
  value       = module.compute.instance_id
}

output "rds_endpoint" {
  description = "RDS connection endpoint (host:port)."
  value       = module.database.endpoint
}

output "product_events_queue_url" {
  description = "Main SQS queue URL."
  value       = module.messaging.queue_url
}

output "product_events_dlq_url" {
  description = "Dead-letter queue URL."
  value       = module.messaging.dlq_url
}

output "ssm_path_prefix" {
  description = "SSM Parameter Store prefix holding runtime config (DB creds, queue URL)."
  value       = local.ssm_path_prefix
}

output "db_password_ssm_parameter" {
  description = "Name of the SecureString SSM parameter holding the DB password."
  value       = aws_ssm_parameter.db_password.name
}
