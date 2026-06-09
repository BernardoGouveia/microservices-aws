# Estado remoto (S3) para o stack do laboratorio Week 9.
# Permite que o CI (GitHub Actions) partilhe o mesmo estado das filas, tornando
# o `terraform apply` idempotente (sem tentar recriar filas que ja existem).
# Sem DynamoDB de proposito: o role do CI (gha-deployer) tem acesso S3 mas nao
# a DynamoDB, e este stack pequeno nao precisa de locking partilhado.
terraform {
  backend "s3" {
    bucket  = "microservices-tfstate-054862141870"
    key     = "envs/week9-sqs/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
