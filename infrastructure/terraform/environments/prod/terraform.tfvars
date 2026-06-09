# NOTA: o PROD é propositadamente mais próximo de produção e NÃO é Free Tier.
# RDS Multi-AZ, NAT gateway e proteção contra eliminação têm custo. Para a demo
# aplica o DEV; trata o PROD como o segundo ambiente reproduzível.

aws_region  = "eu-central-1"
project     = "microservices"
environment = "prod"
owner       = "team-cn"

# Rede
vpc_cidr             = "10.1.0.0/16"
azs                  = ["eu-central-1a", "eu-central-1b"]
public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
enable_nat_gateway   = true

# Computação
instance_type    = "t3.micro"
key_name         = ""
allowed_app_cidr = "0.0.0.0/0"
allowed_ssh_cidr = ""

# Base de dados
db_instance_class      = "db.t3.micro"
db_engine_version      = "16"
db_name                = "appdb"
db_username            = "appuser"
db_multi_az            = true
db_backup_retention    = 7
db_deletion_protection = true
db_skip_final_snapshot = false
