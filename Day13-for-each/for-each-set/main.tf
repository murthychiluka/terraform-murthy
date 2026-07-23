resource "aws_s3_bucket" "buckets" {
  for_each = toset([
    "murthy-dev",
    "murthy-staging",
    "murthy-prod"
  ])

  bucket = each.value

  tags = {
    Name = each.value
  }
}

# Creates:
# aws_s3_bucket.buckets["murthy-dev"]
# aws_s3_bucket.buckets["murthy-staging"]
# aws_s3_bucket.buckets["murthy-prod"]

# Access specific bucket:
output "dev_bucket" {
  value = aws_s3_bucket.buckets["murthy-dev"].bucket
}