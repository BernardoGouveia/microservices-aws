# Infrastructure as Code (Terraform)

Modular Terraform for the microservices platform on AWS. Region `eu-central-1`.

## Layout

```
infrastructure/terraform/
├── bootstrap/            # one-time: S3 state bucket + DynamoDB lock table (local state)
├── modules/
│   ├── network/          # VPC, public/private subnets (2 AZs), IGW, route tables, optional NAT
│   ├── compute/          # EC2 (AL2023, IMDSv2), app security group, least-privilege IAM role
│   ├── database/         # RDS PostgreSQL in private subnets, DB security group + subnet group
│   └── messaging/        # SQS product-events queue + DLQ with redrive
└── environments/
    ├── dev/              # Free-Tier-friendly defaults
    └── prod/             # production-like (Multi-AZ, NAT, deletion protection) — not Free Tier
```

Each environment composes the four modules, generates the RDS password
(`random_password`), and publishes runtime config (DB host/port/name/user,
password as SecureString, and the queue URL) to **SSM Parameter Store** under
`/microservices/<env>/`. The EC2 instance reads those at runtime through its
instance role — no credentials are committed anywhere.

## Module dependency flow

```
network ──┬─> compute ──> database        (database SG ingress = compute app SG)
          └─> (subnets)
messaging ───> compute (IAM queue scope)
database + messaging ──> SSM parameters
```

## One-time: remote state backend

The environments use an S3 backend with DynamoDB locking. Create those first
(they live in their own state because of the chicken-and-egg):

```bash
cd bootstrap
terraform init
terraform apply
```

This creates bucket `microservices-tfstate-054862141870` (versioned, encrypted,
public access blocked) and lock table `microservices-tf-locks`. If you change
those names, update `backend.tf` in **both** environments to match.

## Deploy an environment

```bash
cd environments/dev
terraform init        # configures the S3 backend
terraform plan
terraform apply
```

Useful outputs:

```bash
terraform output ec2_public_ip            # browse / Ansible inventory
terraform output ec2_instance_id          # aws ssm start-session --target <id>
terraform output rds_endpoint             # DB host:port
terraform output product_events_queue_url
terraform output ssm_path_prefix          # /microservices/dev
```

Connect to the instance without SSH keys (the role has SSM core):

```bash
aws ssm start-session --target $(terraform output -raw ec2_instance_id) --region eu-central-1
```

Read runtime config the way the app does:

```bash
aws ssm get-parameters-by-path --path /microservices/dev --recursive \
  --with-decryption --region eu-central-1
```

## Free Tier and cost notes

- `dev` defaults: `t3.micro` EC2, `db.t3.micro` single-AZ Postgres (20 GB), no
  NAT gateway. RDS sits in private subnets and needs no outbound internet, so
  NAT is left off to avoid its hourly charge.
- `prod` enables Multi-AZ RDS, a NAT gateway, and deletion protection — these
  cost money. Apply `dev` for the demo; treat `prod` as the reproducible
  second environment.
- Always `terraform destroy` when finished. `prod` has `deletion_protection`
  on the database; flip `db_deletion_protection = false` and re-apply before
  destroying.

## Security highlights

- No hardcoded credentials. RDS password is generated and stored only in an
  encrypted SSM SecureString parameter.
- RDS is private (`publicly_accessible = false`) and only reachable from the
  app security group on port 5432.
- EC2 enforces IMDSv2 and uses an encrypted root volume.
- The instance role grants exactly: read this environment's SSM parameters,
  decrypt them via SSM only, and the specific SQS actions on the project queues.
```
