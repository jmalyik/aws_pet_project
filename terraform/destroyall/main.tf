provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "eu-north-1"
}

# Lambda function reference for deletion
resource "aws_lambda_function" "pet_project_lambda" {
  function_name = "aws-pet-project-lambda"
  # No other config required; this is just for deletion
}

# S3 bucket for deletion (force_destroy ensures content is also deleted)
resource "aws_s3_bucket" "pet_project_bucket" {
  bucket        = "aws-pet-bucket"
  force_destroy = true
}

# CloudWatch Event Rule used for scheduling
resource "aws_cloudwatch_event_rule" "pet_project_schedule" {
  name = "aws-pet-project-schedule"
}

# Event target pointing to the Lambda function
resource "aws_cloudwatch_event_target" "pet_project_target" {
  rule      = aws_cloudwatch_event_rule.pet_project_schedule.name
  target_id = "pet-project-lambda"
  arn       = aws_lambda_function.pet_project_lambda.arn
}

# Permission for CloudWatch Events to invoke the Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pet_project_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pet_project_schedule.arn
}

# CloudFront key group and public key (used for signed URL setup)
resource "aws_cloudfront_public_key" "pet_public_key" {
  name        = "aws-pet-public-key"
  encoded_key = file("${path.module}/../deploy/public.pem")
  comment     = "Public key for CloudFront signed URLs"
}

resource "aws_cloudfront_key_group" "pet_key_group" {
  name = "aws-pet-key-group"

  items = [aws_cloudfront_public_key.pet_public_key.id]
}

# CloudFront distribution to be deleted
resource "aws_cloudfront_distribution" "pet_distribution" {
  # Only reference the ID for deletion – content omitted
  # You can import and remove via `terraform destroy`
}

# IAM role used by Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"
}

# Secrets Manager secret that holds the private key
resource "aws_secretsmanager_secret" "cloudfront_private_key" {
  name = "cloudfront-private-key"
}
