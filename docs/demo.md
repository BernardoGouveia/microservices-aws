# Roteiro da Defesa / Demonstração

Guião prático para a apresentação: o que mostrar, por que ordem, os comandos da
demo ao vivo, e respostas às perguntas típicas do júri.

> **Regra de ouro:** abre com os **requisitos mandatórios bem feitos**; só depois
> introduz os stretch goals como *"também levámos isto mais longe"*.

---

## 0. Antes da defesa (preparação)

Tem **dois ambientes** prontos (dica do enunciado):
1. **Um ambiente estável já deployado** (deixa o `dev` aplicado antes da defesa).
2. **Capacidade de provisionar ao vivo** (mostrar `terraform apply` a correr).

Re-deploy completo (~5-10 min, a RDS é o que demora):
```powershell
# o bootstrap (estado remoto + alarme billing) ja existe
cd infrastructure\terraform\environments\dev
terraform init ; terraform apply        # VPC + EC2 + RDS + SQS + SSM (34 recursos)
terraform output                        # guarda ec2_public_ip, rds_endpoint, queue URLs
```
Deploy da app (WSL):
```bash
export ANSIBLE_CONFIG=$(pwd)/ansible.cfg   # a partir de ./ansible
export DB_HOST=$(aws ssm get-parameter --name /microservices/dev/db/host --query Parameter.Value --output text --region eu-central-1)
export DB_PASSWORD=$(aws ssm get-parameter --name /microservices/dev/db/password --with-decryption --query Parameter.Value --output text --region eu-central-1)
ansible all -b -m dnf -a "name=python3-pip state=present"
IMAGE_TAG=latest ansible-playbook playbooks/deploy-app.yml
```

**Backup:** grava um **vídeo** da demo a funcionar, caso a rede/AWS falhe no dia.

---

## 1. Pitch de abertura (30 segundos)

> "Construímos um sistema de microsserviços cloud-native na AWS: 4 serviços Spring
> Boot (gateway + user + product + order) que comunicam de forma síncrona (REST/
> OpenFeign) e assíncrona (SQS/Kafka). Toda a infraestrutura é Terraform com estado
> remoto; o deploy é automatizado com Ansible; e o CI/CD em GitHub Actions autentica
> na AWS por OIDC, sem chaves estáticas."

---

## 2. Console walk-through (AWS) — conta a história "rede → compute → dados → mensageria → config → segurança"

| Ordem | Mostrar | Pontos a referir |
|---|---|---|
| 1 | **VPC** | CIDR `10.0.0.0/16`, custom (não default) |
| 2 | **Subnets** | 2 públicas + 2 privadas, **2 AZs** |
| 3 | **Route tables / IGW** | pública → IGW; privada isolada |
| 4 | **Security Groups** | app expõe só a porta da app; **BD só aceita do SG da app** |
| 5 | **EC2** | Amazon Linux 2023, **IMDSv2 obrigatório**, disco encriptado, Docker |
| 6 | **RDS** | PostgreSQL **em sub-rede privada**, `publicly_accessible=false`, encriptada |
| 7 | **SQS** | fila `product-events` + **DLQ** (redrive após 5 falhas) |
| 8 | **SSM Parameter Store** | `/microservices/dev/*` — password como **SecureString** |
| 9 | **IAM + OIDC** | role da EC2 least-privilege; provider OIDC + role `gha-deployer` |

---

## 3. Demonstração ao vivo (pela ordem dos requisitos)

### 3.1 CI/CD (Req 8) — GitHub Actions
- Mostra a aba **Actions** com tudo **verde** (CI, Build All, Image, Terraform, OIDC).
- Abre o **`AWS OIDC Test`**: log mostra `Assuming role with OIDC` + `sts get-caller-identity` → **prova: sem chaves estáticas**.
- Abre o **`Terraform`**: `init` (backend S3) → `plan` → **`apply`** a correr no CI.

### 3.2 IaC (Req 1, 2) — Terraform
```powershell
cd infrastructure\terraform\environments\dev
terraform plan      # mostra o estado reproduzivel; modulos network/compute/database/messaging
```
Refere: **módulos reutilizáveis**, `dev`/`prod`, **estado remoto S3 + lock DynamoDB**.

### 3.3 App + persistência (Req 3, 4, 6) — REST + Feign + RDS
```bash
# product-service na cloud (porta 8082 aberta), ligado ao RDS:
curl -X POST http://<EC2_IP>:8082/products -H "Content-Type: application/json" \
  -d '{"name":"Demo","description":"feito na defesa","price":9.99,"stockQuantity":50}'
curl http://<EC2_IP>:8082/products          # persistido no RDS
```
**Fluxo completo (local)** — user → product → order, com Feign + evento assíncrono:
```bash
docker compose -f docker-compose.kafka.yml up -d
docker compose -f docker-compose.yml -f docker-compose.postgres.yml up --build
# criar user, product, order via :8080/api/... (gateway) — ver stock decrementar
```

### 3.4 Event-driven (Req 5) — SQS + DLQ
```powershell
$Q = "https://sqs.eu-central-1.amazonaws.com/054862141870/microservices-dev-product-events"
aws sqs send-message --queue-url $Q --message-body '{"demo":"evento"}' --region eu-central-1
aws sqs receive-message --queue-url $Q --region eu-central-1
```
Mostra a **DLQ** na consola e explica o **redrive** (após 5 receções falhadas).

### 3.5 Automação (Req 7) — Ansible
```bash
ansible all -m ping                              # conectividade
ansible-playbook playbooks/deploy-app.yml        # deploy idempotente + healthcheck
```

### 3.6 Segurança (Req 9)
- **Sem credenciais no código:** mostra o `application-production.yml` (lê `${DB_*}` de env) e o SSM SecureString.
- **Least-privilege:** mostra a policy inline do role da EC2 (ações explícitas, scoped a `/microservices/<env>/*`).
- **OIDC:** a trust policy só confia em `repo:BernardoGouveia/microservices-aws:*`.

---

## 4. Stretch goals — "também levámos isto mais longe"

1. ⭐ **Secrets em SSM Parameter Store com IAM scoped** — credenciais lidas em runtime, nunca no código; o IAM define exatamente o que cada role lê.
2. **Multi-AZ** — rede em 2 AZs; o ambiente **prod** usa **RDS Multi-AZ**.

(Outros tocados: alarme de billing → SNS/email, tags para cost allocation, backups RDS + versionamento S3, plan comentado no PR, Swagger/OpenAPI, diagrama Mermaid.)

---

## 5. Perguntas típicas do júri (e respostas)

**Porque é que a app usa H2 local e PostgreSQL em produção?**
> Princípio 12-factor + perfis Spring. Em dev local arrancamos sem dependências
> externas (H2 em memória); com `SPRING_PROFILES_ACTIVE=production` ligamos ao RDS.
> As credenciais vêm de variáveis de ambiente, injetadas a partir do SSM.

**Como funciona o OIDC e porque é melhor que chaves de acesso?**
> O GitHub Actions apresenta um token OIDC à AWS, que o troca por credenciais
> **temporárias** (STS) ao assumir o role `gha-deployer`. A trust policy só confia
> neste repositório. Não guardamos `AWS_ACCESS_KEY` nenhuma — se vazasse um token,
> só servia para este repo e expirava em minutos.

**Como garantem o princípio de menor privilégio?**
> O role da EC2 tem **ações explícitas**: `ssm:GetParameter` apenas em
> `/microservices/<env>/*`, `kms:Decrypt` só via SSM, e as ações SQS apenas nas
> filas do projeto. É um role **por ambiente**, não um partilhado.

**As credenciais da BD estão em algum lado no código?**
> Não. A password é **gerada** (`random_password`) no apply, guardada como
> **SecureString** no SSM, e a EC2 lê-a em runtime através do seu role. Nunca toca
> no repositório (o `.gitignore` exclui `*.tfstate`, `.env`, `*.pem`).

**Porque só está um serviço na cloud?**
> O deploy Ansible demonstra a automação com um serviço (product-service), ligado
> ao RDS. A `t3.micro` (1 GB) não comporta os 4 serviços + Kafka. O fluxo
> multi-serviço completo está **provado localmente** com docker-compose.

**O que acontece se a EC2 morrer?**
> Hoje não há auto-replacement — é uma **limitação assumida**. No roadmap está
> ALB + Auto Scaling Group com health checks para self-healing.

**Como tratam o assíncrono e as falhas?**
> O product-service publica `ProductCreated`; o order-service consome de forma
> independente (não bloqueia o produtor). Após **5 receções falhadas**, a mensagem
> vai para a **DLQ** (redrive policy) para inspeção. Localmente é Kafka, na cloud SQS.

**Como é o estado do Terraform e a reprodutibilidade?**
> Estado **remoto** em S3 (versionado, encriptado) com **lock** em DynamoDB, uma
> key por ambiente. O `bootstrap` cria esse backend. Qualquer pessoa reproduz o
> ambiente com `terraform apply` no `dev` ou `prod`.

**E os custos?**
> O `dev` é free-tier (t3.micro, db.t3.micro, sem NAT). Temos um **alarme de
> billing a $5** (SNS → email) e tags para cost allocation. No fim, `terraform
> destroy` deixa o custo a zero.

---

## 6. Limitações (honestas)

Ver [limitations.md](limitations.md): H2 vs RDS por perfil, um único host (sem
HA no tier da app), dois transportes assíncronos (Kafka local / SQS cloud),
`ddl-auto` em vez de migrações versionadas, observabilidade básica.

> Fechar com honestidade: *"sabemos exatamente o que falta e porquê — é o roadmap."*

---

## 7. No fim da defesa

```powershell
cd infrastructure\terraform\environments\dev
terraform destroy        # custo a zero (mantém o bootstrap + alarme)
```
