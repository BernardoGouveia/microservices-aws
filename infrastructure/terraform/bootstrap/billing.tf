# Alarme de billing (obrigatorio: "non-negotiable" no Getting Started).
# IMPORTANTE: as metricas AWS/Billing so existem em us-east-1, por isso usamos um
# provider com alias nessa regiao, mesmo que o resto do projeto seja eu-central-1.

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = var.project
      Owner     = var.owner
      ManagedBy = "terraform"
      Purpose   = "billing-alarm"
    }
  }
}

# Topico SNS que encaminha a notificacao do alarme.
resource "aws_sns_topic" "billing" {
  provider = aws.us_east_1
  name     = "${var.project}-billing-alarm"
}

# Subscricao por email. ATENCAO: e preciso CONFIRMAR no email (link enviado pela AWS).
resource "aws_sns_topic_subscription" "billing_email" {
  provider  = aws.us_east_1
  topic_arn = aws_sns_topic.billing.arn
  protocol  = "email"
  endpoint  = var.billing_alarm_email
}

# Alarme: dispara quando a estimativa de custos ultrapassa o limite (USD).
resource "aws_cloudwatch_metric_alarm" "billing" {
  provider            = aws.us_east_1
  alarm_name          = "${var.project}-billing-gt-${var.billing_alarm_threshold_usd}usd"
  alarm_description   = "Estimativa de custos AWS acima de ${var.billing_alarm_threshold_usd} USD"
  namespace           = "AWS/Billing"
  metric_name         = "EstimatedCharges"
  dimensions          = { Currency = "USD" }
  statistic           = "Maximum"
  period              = 21600 # 6 horas
  evaluation_periods  = 1
  threshold           = var.billing_alarm_threshold_usd
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.billing.arn]
}

output "billing_alarm_topic_arn" {
  description = "ARN do topico SNS do alarme de billing."
  value       = aws_sns_topic.billing.arn
}
