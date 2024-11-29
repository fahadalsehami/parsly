```markdown
# Parsly - Medical Content Generation Infrastructure

## Infrastructure Overview
This project implements the AWS infrastructure for the Parsly medical content generation system as described in the AWS ML blog. The infrastructure includes:

- VPC with public/private subnets
- ECS Fargate for running the Streamlit UI
- Lambda functions for content generation
- Amazon Bedrock for LLM integration
- S3 for document storage
- API Gateway for WebSocket communication
- ECR for container registry

## Prerequisites
- AWS CLI configured
- Terraform >= 1.0.0
- Docker for local development

## Project Structure
```bash
infrastructure/
└── terraform/
    ├── main.tf                # Core infrastructure
    ├── providers.tf           # AWS provider configuration
    ├── variables.tf           # Input variables
    ├── backend.tf             # S3 state backend
    ├── vpc.tf                 # Networking components
    ├── iam.tf                 # IAM roles and policies
    ├── ecs.tf                 # ECS Fargate services
    ├── ecr.tf                 # Container registry
    ├── s3.tf                  # S3 bucket configuration
    ├── lambda.tf             # Lambda functions
    ├── api_gateway.tf        # WebSocket API
    └── outputs.tf            # Output values
```

## Deployment Steps
1. Initialize Terraform:
```bash
cd infrastructure/terraform
terraform init
```

2. Plan deployment:
```bash
terraform plan -out=tfplan
```

3. Apply infrastructure:
```bash
terraform apply tfplan
```

4. Verify deployment:
```bash
terraform output
```

## Infrastructure Components
### 1. VPC and Networking
- VPC with private/public subnets
- Internet Gateway
- Route tables and security groups

### 2. Container Infrastructure
- ECS Fargate cluster
- ECR repository for UI container
- Load balancer for container access

### 3. Serverless Components
- Lambda functions for content processing
- API Gateway for WebSocket communication
- S3 buckets for document storage

### 4. Security
- IAM roles with least privilege
- VPC endpoint security
- Network ACLs and security groups
```