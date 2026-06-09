# Saídas do módulo de mensageria (URLs/ARNs das filas).

output "queue_url" {
  description = "URL of the main product-events queue (producer + consumer)."
  value       = aws_sqs_queue.main.id
}

output "queue_arn" {
  description = "ARN of the main product-events queue."
  value       = aws_sqs_queue.main.arn
}

output "dlq_url" {
  description = "URL of the dead-letter queue."
  value       = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue."
  value       = aws_sqs_queue.dlq.arn
}

# Lista com os dois ARNs, conveniente para limitar as políticas IAM.
output "queue_arns" {
  description = "Both queue ARNs, convenient for IAM policy scoping."
  value       = [aws_sqs_queue.main.arn, aws_sqs_queue.dlq.arn]
}
