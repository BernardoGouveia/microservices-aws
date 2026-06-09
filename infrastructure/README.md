# Infrastructure

All infrastructure-as-code and cloud configuration for the project.

| Path | Purpose |
|------|---------|
| [terraform/](terraform/) | **Canonical IaC** — modular VPC + compute + database + messaging, with `dev`/`prod` environments and S3/DynamoDB remote state. Start here. |
| [github-oidc/](github-oidc/) | IAM trust policy for the GitHub Actions OIDC role (`gha-deployer`), so CI assumes a role instead of using static AWS keys. |
| [week9-sqs/](week9-sqs/) | Standalone Week 9 SQS lab artifact (queue + DLQ), kept as submitted. The same queues are also a reusable module in `terraform/modules/messaging`. |

See [terraform/README.md](terraform/README.md) for the deploy order
(bootstrap → environment) and cost/security notes.
