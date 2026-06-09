# Bootstrap do estado remoto: cria o bucket S3 e a tabela DynamoDB que os
# ambientes (dev/prod) usam como backend. Corre UMA vez, no início.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # O bootstrap usa estado LOCAL de propósito: cria o próprio bucket/tabela que
  # os outros ambientes usam como backend remoto (problema do ovo e da galinha).
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project
      Owner     = var.owner
      ManagedBy = "terraform"
      Purpose   = "terraform-remote-state"
    }
  }
}

# Bucket S3 que guarda os ficheiros de estado do Terraform.
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
}

# Versionamento ativo: permite recuperar versões anteriores do estado.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptação em repouso por omissão (SSE-S3).
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueia qualquer acesso público ao bucket de estado.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Tabela DynamoDB para bloqueio de estado (evita execuções concorrentes).
resource "aws_dynamodb_table" "locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
