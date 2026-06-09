#!/bin/bash
# Script de arranque da EC2 (cloud-init): instala o Docker e o plugin Compose.
set -euo pipefail

# Atualiza o sistema e instala o motor Docker.
dnf update -y
dnf install -y docker
systemctl enable --now docker
# Permite ao utilizador ec2-user usar o docker sem sudo.
usermod -aG docker ec2-user

# Instala o plugin Docker Compose v2 num diretório de pesquisa padrão.
mkdir -p /usr/libexec/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64" \
  -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose
