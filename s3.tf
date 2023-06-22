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

# config used to make the bucket public accesible
resource "aws_s3_bucket_ownership_controls" "frontend-ownership-control" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend-public-access" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "frontend-bucket-acl" {
  depends_on = [
    aws_s3_bucket_public_access_block.frontend-public-access,
    aws_s3_bucket_ownership_controls.frontend-ownership-control
  ]

  bucket = aws_s3_bucket.frontend.id
  acl    = "public-read"
}
