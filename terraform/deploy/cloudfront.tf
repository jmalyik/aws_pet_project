data "aws_cloudfront_key_group" "cf_key_group" {
  name = "cf-key-group"
}

data "terraform_remote_state" "cloudfront_key" {
  backend = "s3"
  config = {
    bucket = "your-remote-state-bucket"
    key    = "cloudfront-key/terraform.tfstate"
    region = "eu-north-1"
  }
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    trusted_key_groups = [var.cloudfront_key_group_id]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
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
