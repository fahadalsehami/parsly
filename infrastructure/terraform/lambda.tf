# Lambda functions 
# lambda.tf

resource "aws_lambda_function" "content_generator" {
  filename         = "lambda.zip"
  function_name    = "${var.project_name}-generator"
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.handler"
  runtime         = "python3.9"
  timeout         = 300
  memory_size     = 1024

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.documents.id
      ENVIRONMENT = var.environment
      BEDROCK_MODEL = "anthropic.claude-3"
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = {
    Name        = "${var.project_name}-generator"
    Environment = var.environment
  }
}

resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-lambda-sg"
    Environment = var.environment
  }
}