#보완할점: cors allowedofigins output으로 가져와서 index와 load 버킷 엔드포인트로 설정,
#EOF? 쉘 스크립트?로 index.html load 링크 내용 loadging 버킷 엔드포인트로 바꾸기"

#timestamp declaration
locals {
  now = timestamp()

  date_br = formatdate("MM-DD", local.now)
}

#date time format
output "locals" {
  value = {
    "now"     = local.now,
    "date_br" = local.date_br,
  }
}

# 19~87row index-bucket
resource "aws_s3_bucket" "index-bucket" {
  bucket = "index${local.date_br}"
}

resource "aws_s3_bucket_acl" "index-bucket-acl" {
  bucket = aws_s3_bucket.index-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "index-onwership" {
  bucket = aws_s3_bucket.index-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "index-public-access-bolock" {
  bucket = aws_s3_bucket.index-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}



resource "aws_s3_object" "index-html" {
  bucket = aws_s3_bucket.index-bucket.id
  key    = "index.html"
  source = "C:/Users/USER/terraform/index.html"
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "index-static-web" {
  bucket = aws_s3_bucket.index-bucket.id

  index_document {
    suffix = "index.html"
  }
}

# 63~105 row loading-bucket 
resource "aws_s3_bucket" "loading-bucket" {
  bucket = "loading${local.date_br}"
}

resource "aws_s3_bucket_acl" "loading-bucket-acl" {
  bucket = aws_s3_bucket.loading-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "loading-onwership" {
  bucket = aws_s3_bucket.loading-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "loading-public-access-bolock" {
  bucket = aws_s3_bucket.loading-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}



resource "aws_s3_object" "loading-html" {
  bucket = aws_s3_bucket.loading-bucket.id
  key    = "loading.html"
  source = "C:/Users/USER/terraform/loading.html"
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "loading-static-web" {
  bucket = aws_s3_bucket.loading-bucket.id

  index_document {
    suffix = "loading.html"
  }
}