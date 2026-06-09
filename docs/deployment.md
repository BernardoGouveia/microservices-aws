# Deployment

Ponta a ponta: provisionar infraestrutura → construir e publicar imagens →
fazer deploy da aplicação. Região `eu-central-1`, conta `054862141870`.

## 1. Estado remoto (uma vez por conta)

```bash
cd infrastructure/terraform/bootstrap
terraform init
terraform apply        # cria o bucket de estado S3 + tabela de lock DynamoDB
```

Se mudares os nomes do bucket/tabela, atualiza o `backend.tf` em ambos os ambientes.

## 2. Provisionar um ambiente

```bash
cd infrastructure/terraform/environments/dev
terraform init         # configura o backend S3
terraform plan
terraform apply
```

Saídas (outputs) que vais usar a seguir:

```bash
terraform output ec2_public_ip            # browser / inventário Ansible
terraform output ec2_instance_id          # alvo da sessão SSM
terraform output rds_endpoint
terraform output product_events_queue_url
terraform output ssm_path_prefix          # /microservices/dev
```

O `dev` é orientado ao Free Tier. O `prod` (Multi-AZ + NAT + proteção contra
eliminação) não é — só fazer deploy deliberadamente.

## 3. Construir e publicar imagens (CI)

O GitHub Actions constrói cada serviço e publica no Docker Hub no merge para
`main` (`build-all.yml`), com tag do commit SHA e `latest`. Secrets necessários:
`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (e `AWS_ROLE_TO_ASSUME` para os jobs AWS).

Para construir localmente em alternativa:

```bash
docker build -t <user>/product-service:dev services/product-service
docker push <user>/product-service:dev
```

## 4. Fazer deploy na EC2 (Ansible)

Coloca o IP da instância em `ansible/inventory/inventory.ini` e, a partir de
`ansible/`:

```bash
ansible-playbook playbooks/playbook.yml         # instala Docker + corre o container
IMAGE_TAG=<tag> ansible-playbook playbooks/deploy-app.yml   # deploy rolling + healthcheck
```

Sem chave SSH? Liga via Session Manager (o papel da instância permite-o):

```bash
aws ssm start-session --target <ec2_instance_id> --region eu-central-1
```

## 5. Verificar

```bash
curl http://<ec2_public_ip>:8082/actuator/health      # -> {"status":"UP"}
# cria um produto e confirma que o order-service registou o evento SQS
```

Ler a configuração de runtime que a aplicação consome:

```bash
aws ssm get-parameters-by-path --path /microservices/dev --recursive \
  --with-decryption --region eu-central-1
```

## 6. Destruir (evitar custos contínuos)

```bash
cd infrastructure/terraform/environments/dev
terraform destroy
```

O `prod` tem `deletion_protection` na base de dados — define
`db_deletion_protection = false` e reaplica antes de destruir.

## Resumo CI/CD

| Trigger | Workflow | Ação |
|---------|----------|------|
| PR / push para `main` | `ci.yml` | Maven validate → compile → verify |
| push para `main` | `build-all.yml` | construir + publicar imagens de todos os serviços |
| PR/push em `infrastructure/week9-sqs/**` | `terraform.yml` | fmt → init → validate → plan (comentário no PR) → apply no main |
| manual (com gate) | `deploy-prod.yml` | deploy de produção com aprovação de ambiente |
