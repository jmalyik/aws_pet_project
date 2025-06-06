variable "lambda_jar_path" {
  type        = string
  description = "Path to the built fat jar file"
  default     = "../../target/aws-pet-project.jar"
}

variable "alpha_vantage_apikey" {
  type        = string
  description = "Alpha Vantage API key"
  default     = "not-defined-value"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
  default     = "aws-pet-bucket"
}

variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS Region to deploy into"
}