# Módulo de rede: cria a VPC, sub-redes públicas e privadas em 2 zonas de
# disponibilidade, o Internet Gateway, as tabelas de rota e (opcionalmente) o NAT.

locals {
  # Número de sub-redes a criar, derivado do comprimento das listas de CIDR.
  public_subnet_count  = length(var.public_subnet_cidrs)
  private_subnet_count = length(var.private_subnet_cidrs)
}

# VPC principal. DNS ativo para permitir nomes de host internos (necessário p/ RDS).
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

# Internet Gateway: dá saída para a internet às sub-redes públicas.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

# Sub-redes públicas (uma por AZ). Recebem IP público automaticamente.
resource "aws_subnet" "public" {
  count                   = local.public_subnet_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-${var.azs[count.index]}"
    Tier = "public"
  })
}

# Sub-redes privadas (uma por AZ). Aqui fica a base de dados (sem IP público).
resource "aws_subnet" "private" {
  count             = local.private_subnet_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-${var.azs[count.index]}"
    Tier = "private"
  })
}

# Tabela de rota pública: encaminha todo o tráfego de saída para o IGW.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-public-rt" })
}

# Associa cada sub-rede pública à tabela de rota pública.
resource "aws_route_table_association" "public" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# O NAT gateway é opcional: as sub-redes privadas só precisam de saída para a
# internet se a aplicação correr lá. Desligado por omissão porque o NAT não
# está incluído no Free Tier (tem custo por hora).
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-eip" })
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat" })

  # Garante que o IGW existe antes do NAT (o NAT depende de saída para a internet).
  depends_on = [aws_internet_gateway.this]
}

# Tabela de rota privada. Só ganha rota de saída (0.0.0.0/0 -> NAT) quando o
# NAT está ativo; caso contrário as sub-redes privadas ficam isoladas.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[0].id
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-private-rt" })
}

# Associa cada sub-rede privada à tabela de rota privada.
resource "aws_route_table_association" "private" {
  count          = local.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
