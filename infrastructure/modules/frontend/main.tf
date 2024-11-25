resource "aws_s3_bucket" "frontend" {
  bucket        = "genai-quickstart-frontend-${var.env_display_id_postfix}"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "frontend" {
  depends_on = [
    aws_s3_bucket_ownership_controls.frontend,
    aws_s3_bucket_public_access_block.frontend,
  ]

  bucket = aws_s3_bucket.frontend.id
  acl    = "private"
}

# Build the frontend
resource "null_resource" "frontend_build_and_deploy" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/frontend-build-deploy.sh ${var.websocket_endpoint} ${aws_s3_bucket.frontend.bucket}"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

## Create Origin Access Control as this is required to allow access to the s3 bucket without public access to the S3 bucket.
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "genai-quickstart-frontend-${var.env_display_id_postfix}"
  description                       = "Origin Access Control for the genai-quickstart-frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

## Create CloudFront distribution group
resource "aws_cloudfront_distribution" "frontend" {
  depends_on = [
    aws_s3_bucket.frontend,
    aws_cloudfront_origin_access_control.frontend
  ]

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.frontend.id
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.frontend.id
    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

## Create policy to allow CloudFront to reach S3 bucket
data "aws_iam_policy_document" "frontend" {
  depends_on = [
    aws_cloudfront_distribution.frontend,
    aws_s3_bucket.frontend
  ]
  statement {
    sid    = "3"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.frontend.bucket}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.frontend.arn
      ]
    }
  }
}

## Assign policy to allow CloudFront to reach S3 bucket
resource "aws_s3_bucket_policy" "frontend" {
  depends_on = [
    aws_cloudfront_distribution.frontend
  ]
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend.json
}