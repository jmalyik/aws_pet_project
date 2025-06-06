variable "lambda_jar_path" {
  type        = string
  description = "Path to the built fat jar file"
  default     = "../../target/aws-pet-project.jar"
}

variable "alpha_vantage_apikey" {
  type        = string
  description = "Alpha Vantage API key"
  default = "not-defined-value"
}

