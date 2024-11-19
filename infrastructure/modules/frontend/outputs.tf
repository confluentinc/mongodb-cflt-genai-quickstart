output "frontend_url" {
  value       = aws_cloudfront_distribution.frontend.domain_name
  description = "The URL of the frontend CloudFront distribution that points to our static website"
}