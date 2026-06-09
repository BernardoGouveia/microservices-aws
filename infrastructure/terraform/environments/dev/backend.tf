# Estado remoto do ambiente DEV: guardado no S3 com bloqueio via DynamoDB.
# O bucket e a tabela são criados primeiro pela pasta ../../bootstrap.
terraform {
  backend "s3" {
    bucket         = "microservices-tfstate-054862141870"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "microservices-tf-locks"
    encrypt        = true
  }
}
