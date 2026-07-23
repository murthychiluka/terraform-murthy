variable "bucket_names" {
  default = [
    "murthy-dev-bucket143",
    "murthystaging-bucket123",
    "murthy-prod-bucket143"
  ]
}

resource "aws_s3_bucket" "buckets" {
  count  = length(var.bucket_names)
  bucket = var.bucket_names[count.index]

  tags = {
    Name        = var.bucket_names[count.index]
    Environment = count.index == 0 ? "dev" : count.index == 1 ? "staging" : "prod"
  }
}

# Output specific bucket
output "dev_bucket" {
  value = aws_s3_bucket.buckets[0].bucket
}

output "all_buckets" {
  value = aws_s3_bucket.buckets[*].bucket
}