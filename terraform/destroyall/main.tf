provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "eu-north-1"
}

resource "aws_lambda_function" "pet_project_lambda" {
  function_name = "aws-pet-project-lambda"
  # Nincs más konfiguráció, mert csak a resource létezése kell a törléshez
  # Ha van lifecycle block, lehet tiltani az erőforrás megőrzését (prevent_destroy = false)
  # Így a terraform destroy törli
}

resource "aws_s3_bucket" "pet_project_bucket" {
  bucket = "aws-pet-bucket"
  force_destroy = true  # Így a bucket tartalma is törlődik
}

resource "aws_cloudwatch_event_rule" "pet_project_schedule" {
  name = "aws-pet-project-schedule"
}

resource "aws_cloudwatch_event_target" "pet_project_target" {
  rule      = aws_cloudwatch_event_rule.pet_project_schedule.name
  target_id = "pet-project-lambda"
  arn       = aws_lambda_function.pet_project_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pet_project_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pet_project_schedule.arn
}
