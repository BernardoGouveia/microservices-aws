# Migração para o repositório novo

Mover o projeto para **https://github.com/BernardoGouveia/microservices-aws**,
preservando o histórico de commits.

## 1. Commit local

Já feito (toda a base de código está committada na branch de trabalho).

## 2. Apontar para o repo novo e fazer push (preserva o histórico)

```bash
git remote add aws https://github.com/BernardoGouveia/microservices-aws.git

# enviar a branch atual como "main" no repo novo
git push aws HEAD:main

# (opcional) enviar todas as branches e tags
git push aws --all
git push aws --tags
```

## 3. Reconfigurar o OIDC na AWS

A `infrastructure/github-oidc/trust-policy.json` **já aponta** para o repo novo
(`repo:BernardoGouveia/microservices-aws:*`). Falta:

1. Substituir `<ACCOUNT_ID>` pelo ID real da conta (`054862141870`).
2. Reaplicar a trust policy no role do CI:

```bash
aws iam update-assume-role-policy \
  --role-name gha-deployer \
  --policy-document file://infrastructure/github-oidc/trust-policy.json
```

> Sem este passo, o `configure-aws-credentials` no GitHub Actions falha, porque
> o role só confia no nome do repositório indicado na trust policy.

## 4. Secrets no repo novo (Settings → Secrets and variables → Actions)

| Secret | Valor |
|--------|-------|
| `AWS_ROLE_TO_ASSUME` | ARN do role `gha-deployer` |
| `DOCKERHUB_USERNAME` | utilizador Docker Hub |
| `DOCKERHUB_TOKEN` | token de acesso Docker Hub |

## 5. Definições do repositório

- **Branch protection** em `main`: exigir PR antes de merge, status checks (CI) e ≥1 review.
- **Collaborators**: adicionar os membros do grupo.
- **Actions**: confirmar que estão ativadas.

## 6. Verificar

- O `push` para `main` dispara o `build-all.yml` (publica imagens).
- Abrir um PR mostra o `ci.yml` e o `terraform.yml` (plan comentado no PR).
- Guardar um print de uma run verde do Actions (prova para a avaliação).
