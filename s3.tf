# Bucket to host the website files
resource "aws_s3_bucket" "frontend" {
  bucket = "frontend-bucket-olx"
}

resource "aws_s3_bucket_website_configuration" "frontend-config-bucket" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

# config to make the cdn access the bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
data "aws_iam_policy_document" "s3-cdn-policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.s3-distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend-bucket-policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.s3-cdn-policy.json
}

resource "aws_s3_bucket_public_access_block" "frontend-public-access" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
