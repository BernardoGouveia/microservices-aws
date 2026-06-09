# Valores concretos do ambiente DEV (otimizado para o Free Tier da AWS).

aws_region  = "eu-central-1"
project     = "microservices"
environment = "dev"
owner       = "team-cn"

# Rede
vpc_cidr             = "10.0.0.0/16"
azs                  = ["eu-central-1a", "eu-central-1b"]
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
enable_nat_gateway   = false # NAT não é Free Tier; a RDS é privada mas não precisa de saída

# Computação
instance_type = "t3.micro"
key_name      = "" # indicar o nome de um key pair para SSH; caso contrário usar Session Manager
# Restringir ao teu próprio IP (ex.: "203.0.113.4/32") antes de expor a app publicamente.
allowed_app_cidr = "0.0.0.0/0"
allowed_ssh_cidr = "" # vazio = sem entrada SSH; ligar com: aws ssm start-session --target <instance-id>

# Base de dados
db_instance_class      = "db.t3.micro"
db_engine_version      = "16"
db_name                = "appdb"
db_username            = "appuser"
db_multi_az            = false
db_backup_retention    = 1
db_deletion_protection = false
db_skip_final_snapshot = true
