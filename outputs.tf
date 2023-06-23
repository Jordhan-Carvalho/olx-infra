output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3-distribution.domain_name
}
