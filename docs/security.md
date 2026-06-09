# Segurança

Como são tratadas a identidade, os segredos e o acesso de rede, e a justificação
de menor privilégio por detrás de cada decisão.

## Sem credenciais no código

- A palavra-passe master do RDS é **gerada** (`random_password`) no momento do
  apply e nunca é escrita no código-fonte. Vive apenas num parâmetro **SSM
  SecureString encriptado** (`/microservices/<env>/db/password`).
- A aplicação lê as credenciais da BD e o URL da fila a partir do SSM em runtime,
  através do papel IAM da instância EC2 — nada sensível é embutido nas imagens ou
  no código.
- O CI autentica-se na AWS via **OIDC do GitHub** (o role `gha-deployer`), por
  isso não são guardadas chaves de acesso AWS de longa duração como secrets.
- O `.gitignore` exclui `*.tfstate*`, `*.pem`, `.env`; o estado é encriptado no S3.

## IAM — menor privilégio

**GitHub Actions (`gha-deployer`).** A trust policy
([`infrastructure/github-oidc/trust-policy.json`](../infrastructure/github-oidc/trust-policy.json))
limita o `sts:AssumeRoleWithWebIdentity` a este repositório e à audiência
`sts.amazonaws.com`, por isso só workflows deste repo podem assumir o role.

**Papel da instância EC2.** A política inline concede exatamente:
- `ssm:GetParameter(s)` / `GetParametersByPath` apenas em `/microservices/<env>/*` —
  não em todo o parameter store.
- `kms:Decrypt` **apenas via SSM** (condição
  `kms:ViaService = ssm.<region>.amazonaws.com`), para que o role só consiga
  desencriptar os seus parâmetros SecureString e mais nada.
- As ações SQS específicas (`SendMessage`, `ReceiveMessage`, `DeleteMessage`,
  `GetQueueAttributes`, `GetQueueUrl`, `ChangeMessageVisibility`) apenas nas filas
  do projeto.
- `AmazonSSMManagedInstanceCore` (gerida) para o Session Manager — permite acesso
  shell sem abrir SSH nem distribuir chaves.

**Utilizador de runtime do SQS (laboratório Semana 9).** Política inline dividida
em produtor (`SendMessage`, `GetQueueUrl`) e consumidor (`ReceiveMessage`,
`DeleteMessage`, `GetQueueAttributes`), limitada aos ARNs das filas.

## Isolamento de rede

- O RDS fica em **sub-redes privadas**, `publicly_accessible = false`. O seu grupo
  de segurança só permite entrada a partir do **grupo de segurança da aplicação**
  (não de um CIDR) na porta 5432.
- O grupo de segurança da aplicação expõe apenas a porta da aplicação; o SSH está
  **desligado por omissão** (`allowed_ssh_cidr` vazio), preferindo-se o Session
  Manager.
- As sub-redes privadas não têm rota de saída para a internet, exceto se um NAT
  gateway for explicitamente ativado.

## Endurecimento do host e dos dados

- **IMDSv2 obrigatório** (`http_tokens = "required"`) — mitiga o roubo de
  credenciais dos metadados da instância via SSRF.
- **Encriptação em repouso:** armazenamento RDS encriptado, volume raiz da EC2
  encriptado, bucket de estado S3 com SSE + versionamento + bloqueio de acesso
  público.

## Etiquetagem e governança

As `default_tags` do provider carimbam todos os recursos com `Project`,
`Environment`, `Owner`, `ManagedBy=terraform` para alocação de custos e
responsabilização.

## Trabalho de endurecimento pendente

Ver [limitations.md](limitations.md) — p.ex. restringir `allowed_app_cidr` de
`0.0.0.0/0` para um intervalo conhecido, adicionar VPC endpoints para SQS/SSM
para evitar saída pela internet, e apertar a política de permissões do
`gha-deployer` por ambiente.
