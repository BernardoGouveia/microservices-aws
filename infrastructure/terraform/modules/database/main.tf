# Módulo de base de dados: instância RDS PostgreSQL colocada nas sub-redes
# privadas, acessível apenas a partir do grupo de segurança da aplicação.

# Grupo de sub-redes: indica ao RDS em que sub-redes (privadas) pode ser criado.
resource "aws_db_subnet_group" "this" {
  name        = "${var.name_prefix}-db-subnet-group"
  description = "Private subnets for the RDS instance."
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}

# Grupo de segurança da base de dados. Sem regras de entrada aqui; a regra é
# adicionada abaixo a apontar para o grupo de segurança da aplicação.
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Database tier: inbound only from the application security group."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-sg" })
}

# Permite ligações na porta da BD apenas vindas do tier da aplicação
# (referência ao SG, não a um CIDR -> princípio do menor privilégio na rede).
resource "aws_vpc_security_group_ingress_rule" "from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Database port from the application tier"
  referenced_security_group_id = var.app_security_group_id
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
}

# Instância RDS PostgreSQL.
# - storage_encrypted: dados encriptados em repouso.
# - publicly_accessible = false: nunca exposta à internet.
# - password: fornecida pelo chamador (gerada), nunca escrita no código.
resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-db"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az               = var.multi_az
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  # Só define o nome do snapshot final quando NÃO se ignora o snapshot.
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-db-final"
  apply_immediately         = var.apply_immediately

  tags = merge(var.tags, { Name = "${var.name_prefix}-db" })
}
