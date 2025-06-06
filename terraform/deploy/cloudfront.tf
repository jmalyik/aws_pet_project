resource "aws_cloudfront_key_group" "cf_key_group" {
  name = "cf-key-group"

  items = [
    aws_cloudfront_public_key.cf_public_key.id
  ]
}

resource "aws_cloudfront_public_key" "cf_public_key" {
  name        = "cf-public-key"
  encoded_key = file("${path.module}/public.pem") # RSA public key from CI/CD
  comment     = "Public key for signed URLs"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = "" # Not needed for signed URLs; leave blank or use OAC if needed
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    trusted_key_groups = [
      aws_cloudfront_key_group.cf_key_group.id
    ]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "aws-pet-project-cf"
  }
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cf_distribution.id
}
