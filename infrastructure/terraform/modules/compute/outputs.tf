# Saídas do módulo de computação (identificadores e IPs da instância).

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance (null when no public IP)."
  value       = aws_instance.app.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.app.public_dns
}

output "private_ip" {
  description = "Private IP of the EC2 instance."
  value       = aws_instance.app.private_ip
}

# ID do grupo de segurança da app -> usado como origem na regra de entrada da BD.
output "security_group_id" {
  description = "ID of the application security group (source for the DB ingress rule)."
  value       = aws_security_group.app.id
}

output "iam_role_arn" {
  description = "ARN of the instance IAM role."
  value       = aws_iam_role.ec2.arn
}

output "iam_role_name" {
  description = "Name of the instance IAM role."
  value       = aws_iam_role.ec2.name
}
