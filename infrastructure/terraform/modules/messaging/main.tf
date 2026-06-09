# Módulo de mensageria: fila SQS principal "product-events" + fila de mensagens
# mortas (DLQ). Refatoração do laboratório da Semana 9 num módulo reutilizável.

# Fila de mensagens mortas: recebe as mensagens que falharam o processamento.
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name_prefix}-product-events-dlq"
  message_retention_seconds = var.dlq_retention_seconds

  tags = merge(var.tags, { Name = "${var.name_prefix}-product-events-dlq" })
}

# Fila principal. A redrive_policy move a mensagem para a DLQ após N receções
# falhadas (desacoplamento produtor/consumidor com tolerância a falhas).
resource "aws_sqs_queue" "main" {
  name                       = "${var.name_prefix}-product-events"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.tags, { Name = "${var.name_prefix}-product-events" })
}

# Permite que apenas a fila principal faça redrive para a DLQ (boa prática).
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.main.arn]
  })
}
