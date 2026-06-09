# Week 9 — SQS Submission Notes (student 22204317)

Account: `054862141870` · Region: `eu-central-1`

## General requirement — branch
The SQS Java/Spring code lives on `feature/sqs` (later merged to `main`).
```bash
git checkout feature/sqs
git branch        # confirms * feature/sqs
```

## Activity 1 — Queues via AWS Console
Created two Standard queues:
- Main: `cn-course-product-events` — VisibilityTimeout=60s, MessageRetentionPeriod=4 days, ReceiveMessageWaitTimeSeconds=20s (long polling)
- DLQ: `cn-course-product-events-dlq` — MessageRetentionPeriod=14 days
- Redrive policy on main queue → DLQ, maxReceiveCount=5

## Activity 2 — Queues via AWS CLI
```bash
# DLQ
aws sqs create-queue --queue-name cn-cli-product-events-dlq --region eu-central-1 \
  --attributes MessageRetentionPeriod=1209600
# DLQ ARN
aws sqs get-queue-attributes \
  --queue-url https://sqs.eu-central-1.amazonaws.com/054862141870/cn-cli-product-events-dlq \
  --attribute-names QueueArn --region eu-central-1
# Main queue
aws sqs create-queue --queue-name cn-cli-product-events --region eu-central-1 \
  --attributes VisibilityTimeout=60,MessageRetentionPeriod=345600,ReceiveMessageWaitTimeSeconds=20
# Redrive policy (main -> DLQ, maxReceiveCount=5)
aws sqs set-queue-attributes \
  --queue-url https://sqs.eu-central-1.amazonaws.com/054862141870/cn-cli-product-events \
  --region eu-central-1 \
  --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:eu-central-1:054862141870:cn-cli-product-events-dlq\",\"maxReceiveCount\":\"5\"}"}'
# Verify
aws sqs get-queue-attributes \
  --queue-url https://sqs.eu-central-1.amazonaws.com/054862141870/cn-cli-product-events \
  --region eu-central-1 \
  --attribute-names QueueArn VisibilityTimeout ReceiveMessageWaitTimeSeconds MessageRetentionPeriod RedrivePolicy
```

## Activity 3 — Queues via Terraform
Config in this folder (`main.tf`, `variables.tf`, `outputs.tf`). Ran with a distinct prefix to avoid name clashes:
```bash
terraform init
terraform plan  -var="name_prefix=cn-tf"
terraform apply -var="name_prefix=cn-tf" -auto-approve
```
Output `product_events_queue_url = https://sqs.eu-central-1.amazonaws.com/054862141870/cn-tf-product-events`

## Activity 4 — IAM least-privilege
Policy `sqs-microservice-policy.json` (in this folder), attached as an inline policy to IAM user `Bernardo-a22204317`.
Grants exactly: `sqs:SendMessage`, `sqs:GetQueueUrl` (producer) and `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes` (consumer).
Note: a separate AWS-managed `AmazonSQSFullAccess` was attached *temporarily* to provision queues via CLI/Terraform (admin task), then detached — keeping the runtime policy least-privilege.

## Activity 5 — Application configuration (env vars)
```bash
export AWS_REGION=eu-central-1
export CLOUD_SQS_PRODUCT_EVENTS_ENABLED=true
export CLOUD_SQS_PRODUCT_EVENTS_QUEUE_URL="https://sqs.eu-central-1.amazonaws.com/054862141870/cn-course-product-events"
export CLOUD_SQS_PRODUCT_EVENTS_CONSUMER_ENABLED=true
export CLOUD_SQS_PRODUCT_EVENTS_CONSUMER_QUEUE_URL="https://sqs.eu-central-1.amazonaws.com/054862141870/cn-course-product-events"
```
Started product-service (8082) + order-service (8083) with Kafka running. After `POST /products`, order-service logged:
```
SQS product event: type=ProductCreated productId=1 name=SQS Test price=19.99
```

## Activity 6 — Dead-Letter Queue
**Cause of failure:** A message with invalid JSON (`this-is-not-valid-json`) was sent to the main queue. The consumer (`ProductEventSqsPollingConsumer`) failed to deserialize it (Jackson exception) and did NOT delete it. After the visibility timeout the message was redelivered; after 5 receives (maxReceiveCount=5) SQS moved it to the DLQ automatically.

**How to reprocess after fixing:** Fix the consumer, then use SQS **DLQ redrive** (console: open DLQ → *Start DLQ redrive* → send back to source queue), or manually receive from the DLQ and re-send to the main queue. Messages then re-enter normal processing.

## Activity 7 — FIFO (optional)
Not implemented.
