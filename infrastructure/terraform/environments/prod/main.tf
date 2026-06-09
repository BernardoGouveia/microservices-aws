# Ambiente PROD: mesma composição de módulos que o DEV, mas com valores mais
# próximos de produção (ver terraform.tfvars).

locals {
  # Prefixo de nomes, ex.: "microservices-prod".
  name_prefix = "${var.project}-${var.environment}"
  # Caminho base dos parâmetros SSM deste ambiente.
  ssm_path_prefix = "/${var.project}/${var.environment}"
}

# Palavra-passe da BD gerada automaticamente. Nunca é escrita em código; só
# sai do Terraform através do parâmetro SSM encriptado mais abaixo.
resource "random_password" "db" {
  length  = 32
  special = false # evita caracteres não permitidos pelo RDS (/, @, ", espaço)
}

# Rede: VPC, sub-redes, IGW e tabelas de rota.
module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
}

# Mensageria: filas SQS (principal + DLQ).
module "messaging" {
  source = "../../modules/messaging"

  name_prefix = local.name_prefix
}

# Computação: EC2 na sub-rede pública, com papel IAM de privilégios mínimos.
module "compute" {
  source = "../../modules/compute"

  name_prefix      = local.name_prefix
  aws_region       = var.aws_region
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.public_subnet_ids[0]
  instance_type    = var.instance_type
  key_name         = var.key_name
  allowed_ssh_cidr = var.allowed_ssh_cidr
  allowed_app_cidr = var.allowed_app_cidr
  sqs_queue_arns   = module.messaging.queue_arns # limita o acesso SQS a estas filas
  ssm_path_prefix  = local.ssm_path_prefix
}

# Base de dados: RDS PostgreSQL nas sub-redes privadas. A entrada só é
# permitida ao grupo de segurança da aplicação (módulo compute).
module "database" {
  source = "../../modules/database"

  name_prefix             = local.name_prefix
  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.private_subnet_ids
  app_security_group_id   = module.compute.security_group_id
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db.result
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
}

# --- Configuração de runtime (lida pela EC2 através do papel da instância) ----

resource "aws_ssm_parameter" "db_host" {
  name  = "${local.ssm_path_prefix}/db/host"
  type  = "String"
  value = module.database.address
}

resource "aws_ssm_parameter" "db_port" {
  name  = "${local.ssm_path_prefix}/db/port"
  type  = "String"
  value = tostring(module.database.port)
}

resource "aws_ssm_parameter" "db_name" {
  name  = "${local.ssm_path_prefix}/db/name"
  type  = "String"
  value = module.database.db_name
}

resource "aws_ssm_parameter" "db_username" {
  name  = "${local.ssm_path_prefix}/db/username"
  type  = "String"
  value = module.database.username
}

# Palavra-passe guardada como SecureString (encriptada com a chave KMS do SSM).
resource "aws_ssm_parameter" "db_password" {
  name  = "${local.ssm_path_prefix}/db/password"
  type  = "SecureString"
  value = random_password.db.result
}

resource "aws_ssm_parameter" "queue_url" {
  name  = "${local.ssm_path_prefix}/sqs/product-events-url"
  type  = "String"
  value = module.messaging.queue_url
}
