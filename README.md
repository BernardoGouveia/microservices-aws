# Microservices Template - Cloud Computing

This project serves as a **base template** for developing microservices in Java with Spring Boot, designed for educational purposes in Cloud Computing courses.

** IMPORTANT:** This is an initial template. Students must complete the functionalities according to the course plan, including:
- **Dockerfiles** (Week 2) - Create Dockerfiles for each microservice
- **Docker Compose** (Week 2) - Create docker-compose.yml to orchestrate all services
- Additional unit tests
- CI/CD pipelines (Week 10)
- And other functionalities as per the course plan

**Note:** Students must implement Dockerfiles and complete `docker-compose.yml` as part of Week 2 (see course materials).

## Project Overview

This is a microservices-based application demonstrating a modern cloud-native architecture. The project consists of four main services:

1. **API Gateway** - Single entry point for all client requests using Spring Cloud Gateway
2. **User Service** - Manages user data and operations
3. **Product Service** - Manages product catalog and inventory
4. **Order Service** - Manages orders with inter-service communication (Kafka + OpenFeign)

## Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│   API Gateway   │  Port: 8080
│ (Spring Gateway)│
└─────┬───────┬───┬───┘
      │       │   │
      ▼       ▼   ▼
┌──────────┐ ┌──────────────┐ ┌──────────────┐
│   User   │ │   Product   │ │    Order    │
│ Service  │ │   Service   │ │   Service   │
│ Port:    │ │ Port:       │ │ Port:       │
│  8081    │ │  8082       │ │  8083       │
└──────────┘ └──────────────┘ └──────────────┘
      ▲              ▲              │
      │              │              │
      └──────────────┴──────────────┘
              OpenFeign (Sync)
      
      ┌──────────────────────────┐
      │        Kafka             │
      │  (Async Event-Driven)    │
      └──────────────────────────┘
```

## Project Structure

```
microservices-project/
├── services/             # All microservices
│   └── api-gateway/      # API Gateway using Spring Cloud Gateway
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── pt/ulusofona/apigateway/
│   │   │   │       ├── ApiGatewayApplication.java
│   │   │   │       └── config/
│   │   │   │           └── GatewayConfig.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
│   └── user-service/     # User management microservice
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── pt/ulusofona/userservice/
│   │   │   │       ├── UserServiceApplication.java
│   │   │   │       ├── controller/
│   │   │   │       │   ├── UserController.java
│   │   │   │       │   └── GlobalExceptionHandler.java
│   │   │   │       ├── service/
│   │   │   │       │   └── UserService.java
│   │   │   │       ├── repository/
│   │   │   │       │   └── UserRepository.java
│   │   │   │       ├── model/
│   │   │   │       │   └── User.java
│   │   │   │       └── dto/
│   │   │   │           ├── UserRequest.java
│   │   │   │           └── UserResponse.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
│   └── product-service/  # Product management microservice
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── pt/ulusofona/productservice/
│   │   │   │       ├── ProductServiceApplication.java
│   │   │   │       ├── controller/
│   │   │   │       │   ├── ProductController.java
│   │   │   │       │   └── GlobalExceptionHandler.java
│   │   │   │       ├── service/
│   │   │   │       │   └── ProductService.java
│   │   │   │       ├── repository/
│   │   │   │       │   └── ProductRepository.java
│   │   │   │       ├── model/
│   │   │   │       │   └── Product.java
│   │   │   │       └── dto/
│   │   │   │           ├── ProductRequest.java
│   │   │   │           └── ProductResponse.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
│   └── order-service/    # Order management microservice (Kafka + OpenFeign)
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── pt/ulusofona/orderservice/
│   │   │   │       ├── OrderServiceApplication.java
│   │   │   │       ├── controller/
│   │   │   │       │   ├── OrderController.java
│   │   │   │       │   └── GlobalExceptionHandler.java
│   │   │   │       ├── service/
│   │   │   │       │   └── OrderService.java
│   │   │   │       ├── repository/
│   │   │   │       │   └── OrderRepository.java
│   │   │   │       ├── model/
│   │   │   │       │   ├── Order.java
│   │   │   │       │   ├── OrderItem.java
│   │   │   │       │   └── OrderStatus.java
│   │   │   │       ├── dto/
│   │   │   │       │   ├── OrderRequest.java
│   │   │   │       │   ├── OrderResponse.java
│   │   │   │       │   └── OrderItemRequest.java
│   │   │   │       ├── client/
│   │   │   │       │   ├── UserServiceClient.java (OpenFeign)
│   │   │   │       │   └── ProductServiceClient.java (OpenFeign)
│   │   │   │       ├── event/
│   │   │   │       │   ├── OrderCreatedEvent.java
│   │   │   │       │   └── OrderStatusChangedEvent.java
│   │   │   │       └── config/
│   │   │   │           └── KafkaConfig.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
├── Aulas/                # Course materials and documentation
├── README.md             # This file
└── API_EXAMPLES.md       # API usage examples
```

## Technologies Used

- **Java 21** (LTS) - Programming language
- **Spring Boot 3.4.0** - Application framework (latest stable version)
- **Spring Cloud 2024.0.0** - Latest release train for microservices
- **Spring Cloud Gateway** - API Gateway for routing and load balancing
- **Spring Data JPA** - Data persistence abstraction
- **Spring Kafka** - Asynchronous messaging and event-driven communication
- **OpenFeign** - Declarative HTTP client for synchronous inter-service communication
- **H2 Database** - In-memory database for development
- **Apache Kafka** - Distributed event streaming platform
- **JUnit 5 & Mockito** - Unit testing framework
- **Maven** - Dependency management and build tool
- **Lombok 1.18.34** - Reduces boilerplate code (latest version)
- **Spring Boot Actuator** - Monitoring and health checks
- **Jakarta Validation** - Bean validation framework
- **SpringDoc OpenAPI 2.6.0** - API documentation (Swagger UI)
- **Micrometer & Prometheus** - Metrics collection and observability
## Prerequisites

Before running this project, ensure you have the following installed:

- **Java 21** (LTS) - **Required**
  - Check installation: `java -version`
  - **Important:** This project requires Java 21. Java 25+ may have compatibility issues with Lombok.
  - Download from: [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://openjdk.org/)
  - On macOS, you can install via Homebrew: `brew install openjdk@21`
  - Set JAVA_HOME: `export JAVA_HOME=$(/usr/libexec/java_home -v 21)`
- **Maven 3.8+**
  - Check installation: `mvn -version`
  - Download from: [Apache Maven](https://maven.apache.org/download.cgi)
- **Git**
  - Check installation: `git --version`
  - Download from: [Git](https://git-scm.com/downloads)
- **Docker** (Optional, for running Kafka and services via docker-compose)
  - Check installation: `docker --version`
  - Download from: [Docker](https://www.docker.com/get-started)
- **IDE** (Recommended: IntelliJ IDEA, Eclipse, or VS Code)
  - **Note:** If using IntelliJ IDEA, ensure Lombok plugin is installed and annotation processing is enabled

## How to Run Locally

### Option 1: Run Each Service Separately

Open three separate terminal windows:

**Terminal 1 - User Service:**
```bash
cd services/user-service
mvn spring-boot:run
```

**Terminal 2 - Product Service:**
```bash
cd services/product-service
mvn spring-boot:run
```

**Terminal 3 - Order Service:**
```bash
cd services/order-service
mvn spring-boot:run
```

**Terminal 4 - API Gateway:**
```bash
cd services/api-gateway
mvn spring-boot:run
```

**Important:** Before starting the services, **Kafka must be running**. Otherwise you will see errors like *"Node 1 disconnected"* or *"Connection to node 1 (localhost:9092) could not be established"*. To start only Kafka and Zookeeper (recommended for local development):
```bash
docker-compose -f docker-compose.kafka.yml up -d
# Wait a few seconds for Kafka to be ready, then start the services
```

### Option 2: Build and Run JAR Files

```bash
# Build all services
mvn clean package

# Run User Service
cd services/user-service
java -jar target/user-service-1.0.0.jar

# Run Product Service (in another terminal)
cd services/product-service
java -jar target/product-service-1.0.0.jar

# Run API Gateway (in another terminal)
cd services/api-gateway
java -jar target/api-gateway-1.0.0.jar
```

### Service Endpoints

Once all services are running, they will be available at:

- **API Gateway**: http://localhost:8080
- **User Service**: http://localhost:8081
- **Product Service**: http://localhost:8082
- **Order Service**: http://localhost:8083

**Kafka** should be running on:
- **Kafka Broker**: localhost:9092
- **Zookeeper**: localhost:2181

## API Endpoints

### API Gateway (Port 8080)

All requests should go through the API Gateway:

- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product
- `GET /api/orders` - List all orders
- `GET /api/orders/{id}` - Get order by ID
- `GET /api/orders/user/{userId}` - Get orders by user ID
- `POST /api/orders` - Create new order
- `PUT /api/orders/{id}/status` - Update order status

### User Service (Port 8081)

Direct access to User Service (bypassing gateway):

- `GET /users` - List all users
- `GET /users/{id}` - Get user by ID
- `POST /users` - Create new user
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user

### Product Service (Port 8082)

Direct access to Product Service (bypassing gateway):

- `GET /products` - List all products
- `GET /products/{id}` - Get product by ID
- `POST /products` - Create new product
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Delete product

### Order Service (Port 8083)

Direct access to Order Service (bypassing gateway):

- `GET /orders` - List all orders
- `GET /orders/{id}` - Get order by ID
- `GET /orders/user/{userId}` - Get orders by user ID
- `POST /orders` - Create new order
- `PUT /orders/{id}/status?status={status}` - Update order status

## Running Tests

Execute tests for each service:

```bash
# Set Java 21 (if not default)
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Run User Service tests
cd services/user-service
mvn test

# Run Product Service tests
cd services/product-service
mvn test

# Run Order Service tests
cd services/order-service
mvn test

# Run API Gateway tests
cd services/api-gateway
mvn test

# Run all tests from root
mvn test -pl user-service,product-service,order-service,api-gateway
```

### Test Coverage

The project uses **JaCoCo** for coverage. Each module enforces a minimum line coverage (85% for services, 70% for API Gateway). After running `mvn test`, open the report at `target/site/jacoco/index.html` in each module.

- **User Service**: Controller tests (CRUD + validation + exception handler), Service tests (all branches including email-in-use), GlobalExceptionHandler, Application context
- **Product Service**: Controller tests (CRUD + search + exception handler), Service tests (including null stockQuantity branches), OrderEventConsumer (success, product not found, insufficient stock, multiple items, save failure), GlobalExceptionHandler, Application context
- **Order Service**: Controller tests (create, validation, get by id, exception handler), Service tests (create/get/update, user/product not found, insufficient stock), GlobalExceptionHandler, Order model (addOrderItem, calculateTotal), Application context
- **API Gateway**: Application context (loads GatewayConfig)

All tests use:
- **JUnit 5** for test framework
- **Mockito** for mocking dependencies
- **Spring Boot Test** for integration tests
- **JaCoCo** for coverage reports and minimum coverage checks
- **MockMvc** for controller testing
- **Spring Kafka Test** for Kafka integration testing

### Best Practices Implemented

- ✅ **OpenAPI/Swagger Documentation** - Complete API documentation for all services
- ✅ **Observability** - Prometheus metrics via Actuator
- ✅ **Comprehensive Testing** - Unit and integration tests with high coverage
- ✅ **Error Handling** - Global exception handlers with proper HTTP status codes
- ✅ **Validation** - Jakarta Validation for request validation
- ✅ **Modern Dependencies** - Latest stable versions of all frameworks
- ✅ **API Gateway** - Centralized routing with order service support

## Inter-Service Communication

This project demonstrates two types of inter-service communication:

### 1. Synchronous Communication (OpenFeign)

**Order Service** uses OpenFeign to make synchronous HTTP calls to:
- **User Service** - Validates user existence before creating orders
- **Product Service** - Validates products and fetches product details

**Example Flow:**
```
Order Service → (OpenFeign) → User Service: Validate user
Order Service → (OpenFeign) → Product Service: Validate products & get details
Order Service: Create order
```

### 2. Asynchronous Communication (Kafka)

**Order Service** publishes events to Kafka topics:
- `order-created` - Published when a new order is created
- `order-status-changed` - Published when order status changes

**Product Service** consumes events from Kafka:
- Listens to `order-created` topic to update inventory

**Example Flow:**
```
Order Service: Creates order → Publishes OrderCreatedEvent to Kafka
Product Service: Consumes event → Updates product inventory
```

### 3. Optional Amazon SQS (Week 10 – cloud lab)

The template also includes **optional AWS SQS** wiring for a shared **`product-events`** queue:

- **product-service** publishes a JSON `ProductCreated` event after a successful **`POST /products`** when `cloud.sqs.product-events.enabled=true`.
- **order-service** long-polls the same queue URL and logs received events when `cloud.sqs.product-events-consumer.enabled=true`.

Terraform for queues + DLQ lives in **`infrastructure/week9-sqs/`**. The Week 10 course materials focus on **infrastructure** (queues, IAM, environment variables), not on implementing Java producers or consumers.

## Microservice Architecture

Each microservice follows a layered architecture pattern:

```
┌─────────────────────┐
│   Controller Layer  │  REST API endpoints
├─────────────────────┤
│   Service Layer     │  Business logic
├─────────────────────┤
│  Repository Layer   │  Data access
├─────────────────────┤
│    Model Layer      │  Entity/Domain models
└─────────────────────┘
```

### Layer Responsibilities

1. **Controller Layer** - Handles HTTP requests/responses, input validation
2. **Service Layer** - Contains business logic, transaction management
3. **Repository Layer** - Data access abstraction, database operations
4. **Model Layer** - Entity classes representing database tables
5. **DTO Layer** - Data Transfer Objects for API communication

## Course Tasks by Week

### Week 2 - Docker and Dockerfile
- [ ] Create Dockerfile for each microservice
- [ ] Create docker-compose.yml for local orchestration
- [ ] Test execution with Docker Compose
- [ ] Implement multi-stage builds for optimization

### Week 3 - DockerHub
- [ ] Build Docker images
- [ ] Push to DockerHub or institutional repository
- [ ] Pull and execute in another environment
- [ ] Tag images with version numbers

### Week 4 - AWS CLI
- [ ] Configure AWS CLI
- [ ] Create automation scripts
- [ ] Test AWS service interactions

### Week 5 - AWS Networking
- [ ] Create VPC and subnets
- [ ] Configure route tables
- [ ] Set up security groups
- [ ] Configure internet gateway

### Week 6 - EC2
- [ ] Create EC2 instance
- [ ] Manual container deployment on EC2
- [ ] Configure security groups for services
- [ ] Test remote access

### Week 7 - Cloud Databases
- [ ] Replace H2 with AWS RDS
- [ ] Configure remote database connection
- [ ] Update connection strings
- [ ] Test database connectivity

### Week 8-9 - Terraform
- [ ] Create infrastructure with Terraform
- [ ] Modularize Terraform code
- [ ] Implement state management
- [ ] Create reusable modules

### Week 10 - CI/CD
- [ ] Create GitHub Actions pipeline
- [ ] Implement automated deployment
- [ ] Add automated testing
- [ ] Configure deployment environments

### Week 11 - SQS (event-driven architecture, cloud focus)
- [ ] Create SQS main queue and DLQ (Terraform in `infrastructure/week9-sqs/`, or Console / CLI)
- [ ] Configure redrive policy and sensible visibility timeout / long polling
- [ ] Grant IAM least privilege (`SendMessage` / `ReceiveMessage` / `DeleteMessage`, etc.)
- [ ] Enable the template via `CLOUD_SQS_*` environment variables and verify logs end-to-end

### Week 12 - Ansible
- [ ] Create Ansible playbooks
- [ ] Automate configuration management
- [ ] Implement infrastructure provisioning
- [ ] Configure application deployment

## API Usage Examples

See **[API_EXAMPLES.md](API_EXAMPLES.md)** for practical API usage examples with curl commands and request/response samples.

## Important Notes

1. **Java Version**: **This project requires Java 21 (LTS)**. Java 25+ has compatibility issues with Lombok. See [COMPILATION.md](COMPILATION.md) for details.
2. **Database**: Currently uses H2 in-memory database. Should be replaced with AWS RDS in Week 7.
3. **Docker (Week 2)**: 
   - **Students must create Dockerfiles** for each service (user-service, product-service, order-service, api-gateway)
   - **Students must complete docker-compose.yml** in the project root (TODO structure is provided)
   - See `Aulas/Week-02/` for detailed instructions
4. **Tests**: Comprehensive unit tests are included (44+ test methods). All tests pass with Java 21.
5. **CI/CD**: Pipelines must be created by students in Week 10.
6. **Kafka**: Required for Order Service. Students will configure this in docker-compose.yml (Week 2).
7. **Inter-Service Communication**: 
   - **Synchronous**: OpenFeign (Order Service → User/Product Services)
   - **Asynchronous**: Kafka (Order Service publishes events, Product Service consumes)
3. **Tests**: Basic tests are included as examples. Students should expand test coverage.
4. **CI/CD**: Pipelines must be created by students in Week 10.
5. **Configuration**: Service URLs are hardcoded for local development. Will be updated when Docker Compose is implemented.

## Health Checks & Observability

Spring Boot Actuator is configured for health monitoring and observability:

### Health Endpoints
- **User Service**: http://localhost:8081/actuator/health
- **Product Service**: http://localhost:8082/actuator/health
- **Order Service**: http://localhost:8083/actuator/health
- **API Gateway**: http://localhost:8080/actuator/health

### Metrics (Prometheus)
- **User Service**: http://localhost:8081/actuator/prometheus
- **Product Service**: http://localhost:8082/actuator/prometheus
- **Order Service**: http://localhost:8083/actuator/prometheus
- **API Gateway**: http://localhost:8080/actuator/prometheus

### API Documentation (Swagger UI)
- **User Service**: http://localhost:8081/swagger-ui.html
- **Product Service**: http://localhost:8082/swagger-ui.html
- **Order Service**: http://localhost:8083/swagger-ui.html
- **API Gateway**: http://localhost:8080/swagger-ui.html

### OpenAPI JSON
- **User Service**: http://localhost:8081/api-docs
- **Product Service**: http://localhost:8082/api-docs
- **Order Service**: http://localhost:8083/api-docs
- **API Gateway**: http://localhost:8080/api-docs

## Development Guidelines

### Code Style
- Follow Java naming conventions
- Use meaningful variable and method names
- Add Javadoc comments for public methods
- Keep methods focused and single-purpose

### Testing
- Write unit tests for service layer
- Write integration tests for controllers
- Aim for at least 70% code coverage
- Use meaningful test method names

### Error Handling
- Use appropriate HTTP status codes
- Provide meaningful error messages
- Log errors appropriately
- Handle exceptions gracefully

## Running with Docker Compose

**⚠️ IMPORTANT:** Students must complete the `docker-compose.yml` file and create Dockerfiles for each service as part of Week 2 exercises.

Once you've completed `docker-compose.yml` and built images from your Dockerfiles:

```bash
# Start all services (Kafka, Zookeeper, and all microservices)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

**Note:** 
- Make sure Docker is installed and running
- You must create Dockerfiles for each service first (Week 2)
- See `Aulas/Week-02/` for detailed instructions

## CI/CD Pipeline (Week 10 — GitHub Actions)

All workflows live under [`.github/workflows/`](.github/workflows/) and run on GitHub-hosted Ubuntu runners.

### Repository layout

This repo follows the suggested project layout:

| Component | Location |
|-----------|----------|
| Services  | `services/<svc>/` |
| Terraform | `infrastructure/terraform/` (modules + `dev`/`prod` environments) |
| Ansible   | `ansible/` |
| Docs      | `docs/` |

The standalone Week 9 SQS lab artifact lives in `infrastructure/week9-sqs/`.

### Workflow inventory

| File                                                                | Activity | Trigger                                  | What it does                                                                  |
|---------------------------------------------------------------------|----------|------------------------------------------|-------------------------------------------------------------------------------|
| [`hello.yml`](.github/workflows/hello.yml)                          | 1        | push, `workflow_dispatch`                | Smoke test — prints repo/branch/SHA/actor                                     |
| [`ci.yml`](.github/workflows/ci.yml)                                | 2        | PR, push to `main`                       | Maven `validate` → `compile` → `verify`; uploads Surefire reports             |
| [`image.yml`](.github/workflows/image.yml)                          | 3        | push to `main`, `workflow_dispatch`      | Builds & pushes `product-service` to Docker Hub, tagged `latest` and `<sha>`  |
| [`aws-test.yml`](.github/workflows/aws-test.yml)                    | 4        | `workflow_dispatch`                      | Assumes IAM role via OIDC and runs `aws sts get-caller-identity`              |
| [`terraform.yml`](.github/workflows/terraform.yml)                  | 5        | PR/push touching `infrastructure/week9-sqs/**`    | `fmt` → `init` → `validate` → `plan` (comments on PR) → `apply` on `main`     |
| [`build-all.yml`](.github/workflows/build-all.yml)                  | 6        | push to `main`, `workflow_dispatch`      | Matrix build & push for `user-service`, `product-service`, `order-service`    |
| [`deploy-prod.yml`](.github/workflows/deploy-prod.yml)              | 7        | `workflow_dispatch`                      | `deploy-prod` job gated on the `production` environment (manual approval)     |
| [`reusable-image.yml`](.github/workflows/reusable-image.yml)        | 8        | `workflow_call` (reusable)               | Parameterised Docker build & push, called by `release.yml`                    |
| [`release.yml`](.github/workflows/release.yml)                      | 8        | tag `v*`                                 | Invokes `reusable-image.yml` for `product-service` on a version tag           |
| [`notify.yml`](.github/workflows/notify.yml)                        | 10       | `workflow_dispatch`                      | Writes a job summary and posts to Slack via webhook                           |

### Required GitHub secrets

Set under **Settings → Secrets and variables → Actions**:

| Secret                | Used by                                | How to get it                                                                              |
|-----------------------|----------------------------------------|--------------------------------------------------------------------------------------------|
| `DOCKERHUB_USERNAME`  | `image.yml`, `build-all.yml`, `reusable-image.yml` | Your Docker Hub username                                                                   |
| `DOCKERHUB_TOKEN`     | same as above                          | Docker Hub → Account Settings → Personal Access Tokens → New Token (Read & Write)         |
| `AWS_ROLE_TO_ASSUME`  | `aws-test.yml`, `terraform.yml`        | ARN of the `gha-deployer` IAM role (see AWS OIDC setup below)                              |
| `SLACK_WEBHOOK`       | `notify.yml`                           | Slack → Apps → Incoming Webhooks → Add to channel → copy URL                               |

### Docker Hub setup

1. Create a Docker Hub account at https://hub.docker.com if you don't have one.
2. Account Settings → Personal Access Tokens → **New Token**, scope **Read & Write**.
3. Add `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` as GitHub repo secrets.
4. Push to `main` (or run `image.yml` manually) → image lands at:
   ```
   docker pull <DOCKERHUB_USERNAME>/product-service:latest
   docker pull <DOCKERHUB_USERNAME>/product-service:<git-sha>
   ```

### AWS OIDC setup

Lets workflows assume an IAM role without storing long-lived AWS keys.

**1. Create the OIDC identity provider** (one-time per AWS account):

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

**2. Create the IAM role** using the trust policy in this repo at [`infrastructure/github-oidc/trust-policy.json`](infrastructure/github-oidc/trust-policy.json) (replace `<ACCOUNT_ID>` with your AWS account ID first):

```bash
aws iam create-role \
  --role-name gha-deployer \
  --assume-role-policy-document file://infrastructure/github-oidc/trust-policy.json
```

**3. Attach a least-privilege policy** — start with read-only to verify:

```bash
aws iam attach-role-policy \
  --role-name gha-deployer \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

For Terraform (Activity 5) you'll need broader rights (SQS, IAM, S3 for backend state). Use a custom policy scoped to the resources in `infrastructure/week9-sqs/`.

**4. Store the role ARN** as repo secret `AWS_ROLE_TO_ASSUME`:

```
arn:aws:iam::<ACCOUNT_ID>:role/gha-deployer
```

**5. Verify** by running `aws-test.yml` from the Actions tab → `Run workflow`. Output should show:
```
"Arn": "arn:aws:sts::<ACCOUNT_ID>:assumed-role/gha-deployer/<run-id>"
```

### Production environment (Activity 7)

1. **Settings → Environments → New environment** → name it `production`.
2. Under **Deployment protection rules** → check **Required reviewers** → add yourself.
3. Trigger `deploy-prod.yml` manually → the `deploy-prod` job pauses with **"Waiting for review"**.
4. Approve from the Actions run page → job proceeds.

### Triggering each workflow

| Workflow              | How to trigger                                                                          |
|-----------------------|-----------------------------------------------------------------------------------------|
| `hello.yml`           | Any push, or Actions tab → Hello Actions → Run workflow                                 |
| `ci.yml`              | Open a PR, or push to `main`                                                            |
| `image.yml`           | Push to `main`, or Run workflow manually                                                |
| `aws-test.yml`        | Actions tab → AWS OIDC Test → Run workflow                                              |
| `terraform.yml`       | Edit a file under `infrastructure/week9-sqs/` and open a PR; merge to `main` for apply           |
| `build-all.yml`       | Push to `main`, or Run workflow manually                                                |
| `deploy-prod.yml`     | Actions tab → Deploy to Production → Run workflow → approve at the gate                 |
| `release.yml`         | `git tag v0.1.0 && git push origin v0.1.0`                                              |
| `notify.yml`          | Actions tab → Deploy Report & Notify → Run workflow                                     |

### Local workflow testing with `act` (Activity 9)

[`act`](https://github.com/nektos/act) runs workflows inside Docker locally — useful for iterating without push churn.

```bash
# macOS
brew install act

# Windows (winget)
winget install nektos.act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Usage
act -l                  # list workflows and jobs
act pull_request        # simulate a PR event
act -j java-build       # run a specific job by name
act workflow_dispatch -W .github/workflows/hello.yml  # run a specific workflow
```

Secrets can be supplied with `--secret-file .secrets` (file format: `KEY=VALUE` per line — keep it gitignored).

### Docker Hub repository

Images are published to Docker Hub under the user configured in `DOCKERHUB_USERNAME`:

- `<user>/product-service:latest` / `:<sha>` — from `image.yml`
- `<user>/user-service:<sha>` — from `build-all.yml`
- `<user>/product-service:<sha>` — from `build-all.yml`
- `<user>/order-service:<sha>` — from `build-all.yml`

### Terraform usage (CI-driven)

The Terraform configuration in [`infrastructure/week9-sqs/`](infrastructure/week9-sqs/) creates an SQS main queue + DLQ for the product-events flow. CI behaviour:

- **On PR touching `infrastructure/week9-sqs/**`:** `fmt -check`, `init`, `validate`, `plan` runs and the plan is commented back on the PR.
- **On push to `main` touching the same paths:** the same steps plus `terraform apply -auto-approve` against the saved plan.

> ⚠️ The current configuration uses **local state**. For team use, configure an S3 backend with DynamoDB locking before merging real changes to `main`.

## Troubleshooting

### "Node 1 disconnected" / "Connection to node 1 (localhost:9092) could not be established"
This means **Kafka is not running** or not reachable. The application (order-service, product-service) expects a Kafka broker at `localhost:9092`.

**Solution:**
1. Start Kafka and Zookeeper with Docker:
   ```bash
   docker-compose -f docker-compose.kafka.yml up -d
   ```
2. Wait 10–20 seconds for Kafka to be ready, then start the microservices.
3. If you still see the error, check that Kafka is running and that port 9092 is free:
   ```bash
   docker ps | grep kafka
   # Kafka should be listening on 0.0.0.0:9092
   ```

### Bootstrap servers: use `localhost:9092`, not `kafka:9092`
If you set `spring.kafka.bootstrap-servers` to **kafka:9092**, the app can only connect when it runs **inside Docker** (same network as the Kafka container). The hostname `kafka` does not exist on your machine.

- **Running with Maven** (`mvn spring-boot:run`): use **localhost:9092** in `application.yml` (product-service, order-service). Start Kafka with `docker-compose -f docker-compose.kafka.yml up -d`.
- **Running everything in Docker** (e.g. your Week 2 docker-compose): then use **kafka:9092** (or set `SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:9092` in the container environment).

The project defaults are `localhost:9092` so that local development with Maven works.

### Other Kafka connection issues
If services cannot connect to Kafka:
```bash
# Check if Kafka is running
docker ps | grep kafka

# Check Kafka logs
docker-compose -f docker-compose.kafka.yml logs kafka

# Verify Kafka is accessible (optional)
telnet localhost 9092
```

### Port Already in Use
If you get a "port already in use" error:
```bash
# Find process using port
lsof -i :8080  # or 8081, 8082

# Kill process
kill -9 <PID>
```

### Database Connection Issues
- Ensure H2 is properly configured in application.yml
- Check database URL and credentials
- Verify Spring Data JPA is properly configured

### Service Communication Issues
- Verify all services are running
- Check API Gateway routing configuration
- Verify service URLs in GatewayConfig.java

## Contributing

This is an educational template. Students should complete functionalities according to the course plan.

## License

This project is for educational purposes.

## Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Cloud Gateway Documentation](https://spring.io/projects/spring-cloud-gateway)
- [Spring Data JPA Documentation](https://spring.io/projects/spring-data-jpa)
- [Microservices Patterns](https://microservices.io/patterns/)
- [Course Materials](Aulas/README.md)
