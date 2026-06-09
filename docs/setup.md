# Configuração (Setup)

Pré-requisitos e instruções para correr localmente.

## Ferramentas locais

| Ferramenta | Versão | Verificar |
|------------|--------|-----------|
| JDK | 21 (LTS) | `java -version` |
| Maven | 3.8+ | `mvn -version` |
| Docker + Compose | recente | `docker version` |
| Terraform | ≥ 1.5 | `terraform -version` |
| AWS CLI | v2 | `aws --version` |
| Ansible | recente | `ansible --version` (Windows: WSL ou `pip3 install ansible`) |

> O Java 21 é obrigatório — o Java 25+ tem problemas de compatibilidade com o Lombok.

## Pré-requisitos AWS

1. **Conta + identidade.** Uma conta AWS com um utilizador/role IAM para uso via
   CLI (`aws sts get-caller-identity` deve funcionar). Ativar um alarme de billing.
2. **Região.** Tudo aponta para `eu-central-1`. Não misturar regiões.
3. **OIDC para o CI (opcional mas recomendado).** Criar o provider OIDC do GitHub
   e o role `gha-deployer` a partir de
   [`infrastructure/github-oidc/trust-policy.json`](../infrastructure/github-oidc/trust-policy.json),
   e guardar o ARN no secret `AWS_ROLE_TO_ASSUME` do repositório. Os passos
   completos estão no [README](../README.md#aws-oidc-setup) na raiz.
4. **Estado remoto.** Criar o bucket de estado + tabela de lock uma vez (ver
   [deployment.md](deployment.md)).

## Correr localmente

O Kafka tem de estar a correr antes dos serviços (order/product usam-no localmente):

```bash
docker-compose -f docker-compose.kafka.yml up -d
```

Depois iniciar cada serviço (terminais separados), ou compilar e correr os jars:

```bash
mvn clean package
cd services/user-service    && mvn spring-boot:run   # :8081
cd services/product-service && mvn spring-boot:run   # :8082
cd services/order-service   && mvn spring-boot:run   # :8083
cd services/api-gateway     && mvn spring-boot:run   # :8080
```

Ou levantar toda a stack com o Compose, depois de construídas as imagens:

```bash
docker-compose up -d
docker-compose logs -f
```

Health/docs por serviço: `/actuator/health`, `/swagger-ui.html`.

## Testes

```bash
mvn test                                       # todos os módulos
mvn test -pl services/product-service          # um módulo
```

Os relatórios de cobertura JaCoCo ficam em `target/site/jacoco/index.html` de
cada módulo.

## Opcional: SQS em vez de Kafka (laboratório cloud)

Apontar os serviços a uma fila SQS real com variáveis de ambiente:

```bash
export AWS_REGION=eu-central-1
export CLOUD_SQS_PRODUCT_EVENTS_ENABLED=true
export CLOUD_SQS_PRODUCT_EVENTS_QUEUE_URL="https://sqs.eu-central-1.amazonaws.com/<acct>/<queue>"
export CLOUD_SQS_PRODUCT_EVENTS_CONSUMER_ENABLED=true
export CLOUD_SQS_PRODUCT_EVENTS_CONSUMER_QUEUE_URL="$CLOUD_SQS_PRODUCT_EVENTS_QUEUE_URL"
```

## Opcional: testar o perfil `production` (PostgreSQL) localmente

Sem precisar de AWS — levanta um PostgreSQL local e coloca os serviços no perfil
de produção a apontar para ele:

```bash
docker-compose -f docker-compose.kafka.yml up -d
docker compose -f docker-compose.yml -f docker-compose.postgres.yml up --build
```

Os serviços passam a usar PostgreSQL em vez de H2 (ver
[`docker-compose.postgres.yml`](../docker-compose.postgres.yml)). A palavra-passe
aí definida é apenas para teste local; em produção vem do SSM.
