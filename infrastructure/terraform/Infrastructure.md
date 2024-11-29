```markdown
# Parsly - Medical Content Generation System

## Overview
Parsly is a medical content generation system built on AWS services, following the architecture described in the AWS ML blog. It leverages AWS Bedrock for LLM capabilities to generate curated medical content with fact-checking and regulatory compliance features.

## Architecture Components

### Core Infrastructure
- VPC with public/private subnets across 2 AZs
- Internet Gateway and NAT Gateway for network routing
- VPC Endpoints for AWS services

### Container Services
- ECS Fargate cluster for running Streamlit UI
- ECR repository for container images
- Application Load Balancer for traffic distribution

### Serverless Components
- Lambda functions for content generation and processing
- API Gateway WebSocket API for real-time communication
- S3 buckets for document storage and processing

### AI/ML Services
- Amazon Bedrock for LLM integration
- Amazon Textract for document processing
- Amazon Translate for content translation

## Prerequisites
- AWS CLI installed and configured
- Terraform >= 1.0.0
- Docker for local development
- Python 3.9 or higher
- Conda environment manager

## Directory Structure
```
parsly/
├── infrastructure/
│   └── terraform/
│       ├── main.tf             # Core infrastructure
│       ├── providers.tf        # AWS provider config
│       ├── variables.tf        # Input variables
│       ├── backend.tf         # S3 state backend
│       ├── vpc.tf             # Networking
│       ├── iam.tf             # IAM roles/policies
│       ├── ecs.tf             # ECS Fargate
│       ├── ecr.tf             # Container registry
│       ├── s3.tf              # Storage
│       ├── lambda.tf          # Functions
│       ├── api_gateway.tf     # WebSocket API
│       └── outputs.tf         # Output values
```

## Deployment Instructions

### 1. Infrastructure Setup
```bash
# Initialize Terraform backend
aws s3 mb s3://parsly-terraform-state
aws dynamodb create-table \
    --table-name parsly-terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Deploy infrastructure
cd infrastructure/terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 2. Environment Variables
Create a `.env` file:
```env
AWS_REGION=us-east-1
BEDROCK_MODEL=anthropic.claude-3
S3_BUCKET=parsly-dev-docs
```

### 3. Container Deployment
```bash
# Build and push UI container
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url)
docker build -t parsly .
docker tag parsly:latest $(terraform output -raw ecr_repository_url):latest
docker push $(terraform output -raw ecr_repository_url):latest
```

### 4. Lambda Deployment
```bash
cd src
zip -r ../infrastructure/terraform/lambda.zip .
cd ../infrastructure/terraform
terraform apply -target=aws_lambda_function.content_generator
```

## Component Details

### VPC Configuration
- CIDR: 10.0.0.0/16
- Public subnets: 2 (for ALB)
- Private subnets: 2 (for ECS tasks and Lambda)
- NAT Gateway in public subnet
- VPC Endpoints for AWS services

### ECS Configuration
- Fargate launch type
- CPU: 1024 (1 vCPU)
- Memory: 2048MB (2GB)
- Auto-scaling based on CPU/Memory
- CloudWatch logs enabled

### Lambda Functions
- Runtime: Python 3.9
- Memory: 1024MB
- Timeout: 300 seconds
- VPC access enabled
- CloudWatch logs enabled

### Security
- Private subnets for compute resources
- Security groups with minimal access
- S3 bucket encryption enabled
- IAM roles with least privilege

## Monitoring and Logging
- CloudWatch Logs for ECS and Lambda
- CloudWatch Metrics for scaling
- Container Insights enabled
- API Gateway access logging

## Clean Up
```bash
# Destroy infrastructure
terraform destroy

# Clean up backend
aws s3 rb s3://parsly-terraform-state --force
aws dynamodb delete-table --table-name parsly-terraform-locks
```

## Contributing
Follow the AWS infrastructure patterns and keep configurations in infrastructure-as-code.
```