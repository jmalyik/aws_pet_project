resource "aws_cloudfront_public_key" "cf_public_key" {
  name        = "cf-public-key"
  encoded_key = file("${path.module}/public.pem")
  comment     = "Public key for signed URLs"
}

resource "aws_cloudfront_key_group" "cf_key_group" {
  name = "cf-key-group"
  items = [
    aws_cloudfront_public_key.cf_public_key.id
  ]
}

output "cloudfront_public_key_id" {
  value = aws_cloudfront_public_key.cf_public_key.id
}

output "cloudfront_key_group_id" {
  value = aws_cloudfront_key_group.cf_key_group.id
}