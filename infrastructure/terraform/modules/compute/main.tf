# Módulo de computação: instância EC2 para a aplicação, o seu grupo de
# segurança e um papel IAM com privilégios mínimos (SQS + leitura de SSM).

# Conta atual, usada para construir os ARNs das políticas IAM.
data "aws_caller_identity" "current" {}

# Imagem Amazon Linux 2023 mais recente, usada quando não é fornecida uma AMI.
data "aws_ami" "al2023" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  # AMI a usar: a fornecida ou, se vazia, a Amazon Linux 2023 mais recente.
  ami_id = var.ami_id == "" ? data.aws_ami.al2023[0].id : var.ami_id

  # ARN com wildcard que limita o acesso SSM aos parâmetros deste ambiente.
  # Construído a partir de strings (não de recursos) para evitar dependências circulares.
  ssm_parameter_arn = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_path_prefix}/*"

  # Script de arranque (cloud-init): instala o Docker, se ativado.
  user_data = var.install_docker ? file("${path.module}/user_data.sh") : null
}

# Grupo de segurança da aplicação: SSH + porta da app à entrada, tudo à saída.
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Application tier: SSH + app port inbound, all outbound."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-app-sg" })
}

# Regra de SSH (porta 22). Só é criada se for indicado um CIDR; caso contrário
# usa-se o Session Manager (sem abrir SSH).
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count             = var.allowed_ssh_cidr == "" ? 0 : 1
  security_group_id = aws_security_group.app.id
  description       = "SSH"
  cidr_ipv4         = var.allowed_ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Regra da porta da aplicação (API gateway, por omissão 8080).
resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "Application port (API gateway)"
  cidr_ipv4         = var.allowed_app_cidr
  from_port         = var.app_port
  to_port           = var.app_port
  ip_protocol       = "tcp"
}

# Saída livre (necessária para descarregar imagens Docker, falar com SQS, etc.).
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.app.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# --- IAM: papel da instância com privilégios mínimos -------------------------

# Política de confiança: permite que o serviço EC2 assuma este papel.
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

# Política de permissões da aplicação (apenas o estritamente necessário).
data "aws_iam_policy_document" "app" {
  # Ler apenas os parâmetros SSM deste ambiente.
  statement {
    sid       = "ReadAppParameters"
    actions   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = [local.ssm_parameter_arn]
  }

  # Desencriptar parâmetros SecureString, mas só através do serviço SSM.
  statement {
    sid       = "DecryptViaSsm"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${var.aws_region}.amazonaws.com"]
    }
  }

  # Acesso SQS limitado às filas do projeto (só adicionado se forem passados ARNs).
  dynamic "statement" {
    for_each = length(var.sqs_queue_arns) > 0 ? [1] : []
    content {
      sid = "ProductEventsQueueAccess"
      actions = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ChangeMessageVisibility",
      ]
      resources = var.sqs_queue_arns
    }
  }
}

resource "aws_iam_role_policy" "app" {
  name   = "${var.name_prefix}-app-access"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.app.json
}

# Permite acesso por Session Manager sem abrir SSH nem guardar chaves.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Perfil de instância que liga o papel IAM à EC2.
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# --- EC2 ----------------------------------------------------------------------

resource "aws_instance" "app" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = var.associate_public_ip
  # Sem chave -> null (acesso por Session Manager).
  key_name  = var.key_name == "" ? null : var.key_name
  user_data = local.user_data

  # Força o IMDSv2 (proteção contra roubo de credenciais via metadados).
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Disco raiz encriptado.
  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-app" })
}
