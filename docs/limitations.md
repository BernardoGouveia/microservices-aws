# Limitações & roadmap

Relato honesto do que está incompleto e do que faríamos a seguir. (Ser explícito
aqui é intencional — o que é avaliado é a engenharia e os compromissos, não a
completude de funcionalidades.)

## Limitações conhecidas

- **Persistência: H2 em dev, PostgreSQL/RDS em produção.** Por omissão (dev local
  e testes) os serviços usam H2 em memória. Com `SPRING_PROFILES_ACTIVE=production`
  ligam-se ao PostgreSQL (RDS), lendo as credenciais de variáveis de ambiente
  injetadas a partir do SSM. Limitação: o esquema é criado por `ddl-auto: update`
  (adequado à demo); produção real deveria usar migrações versionadas.
- **Um único host de aplicação, sem alta disponibilidade no tier da app.** Uma
  instância EC2 corre o(s) container(s); não há load balancer nem auto-scaling
  group. A falha da instância significa indisponibilidade até substituição.
- **Dois transportes assíncronos.** O Kafka é usado localmente e o SQS na cloud.
  Conveniente para os laboratórios, mas são dois caminhos de código a considerar.
- **O `prod` está definido mas tem custo.** RDS Multi-AZ + NAT + proteção contra
  eliminação são custos reais, por isso o `prod` normalmente não é aplicado —
  serve como o segundo ambiente reproduzível.
- **Estado Terraform misto.** A IaC principal usa estado remoto S3 + DynamoDB,
  mas o artefacto de laboratório autónomo `infrastructure/week9-sqs` ainda usa
  estado local.
- **O CI só aplica a stack do SQS.** O `terraform.yml` está ligado a
  `infrastructure/week9-sqs`. A stack completa de VPC/EC2/RDS é aplicada
  manualmente, porque o role `gha-deployer` está intencionalmente limitado.
- **Observabilidade básica.** Existem endpoints do Spring Actuator + Prometheus,
  mas não há dashboards CloudWatch, alarmes ou logging centralizado.
- **Segredos sem rotação.** A palavra-passe da BD está num SSM SecureString
  (chave KMS por omissão) mas sem política de rotação.

## Roadmap

1. Substituir `ddl-auto: update` por migrações versionadas (Flyway/Liquibase) e
   ler os parâmetros SSM diretamente na aplicação (Spring Cloud AWS) em vez de via env.
2. Colocar um ALB + auto-scaling group à frente do tier da app; adicionar
   self-healing baseado em `/health`.
3. Apontar o CI/CD a `infrastructure/terraform/environments/dev` com um role de
   deploy de menor privilégio por ambiente.
4. Adicionar CloudWatch Logs + alarmes de profundidade de fila/erros → SNS.
5. Adicionar VPC endpoints para SQS/SSM para que as sub-redes privadas alcancem
   a AWS sem NAT.
6. Restringir `allowed_app_cidr` de `0.0.0.0/0` para um intervalo conhecido;
   considerar WAF.
