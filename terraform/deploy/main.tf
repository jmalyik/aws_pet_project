resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "aws-pet-bucket"
  force_destroy = true
}

# to prevent other AWS users to write to our bucket

resource "aws_s3_bucket_ownership_controls" "lambda_bucket_ownership" {
  bucket = aws_s3_bucket.lambda_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_object" "lambda_jar" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "aws-pet-project.jar"
  source = var.lambda_jar_path
  etag   = filemd5(var.lambda_jar_path)
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

# to let lambda to write the bucket, we need this policy

resource "aws_iam_role_policy" "lambda_s3_put_policy" {
  name = "lambda-s3-put-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::aws-pet-bucket/stocks/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "pet_lambda" {
  function_name = "aws-pet-project"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_object.lambda_jar.key
  handler       = "pet.project.LambdaHandler::handleRequest"
  runtime       = "java11"
  memory_size   = 512
  timeout       = 60
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      ALPHA_VANTAGE_APIKEY = var.alpha_vantage_apikey
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]
}

# scheduling

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "lambda-8min-schedule"
  description         = "Run Lambda every 30 mins on weekdays from 9:00 to 17:00"
  schedule_expression = "cron(0/30 9-17 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.pet_lambda.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pet_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}


