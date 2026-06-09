# Estado remoto do ambiente PROD: S3 + bloqueio via DynamoDB.
# Usa o mesmo bucket que o DEV, mas uma chave (key) diferente.
terraform {
  backend "s3" {
    bucket         = "microservices-tfstate-054862141870"
    key            = "envs/prod/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "microservices-tf-locks"
    encrypt        = true
  }
}
