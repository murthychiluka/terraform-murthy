# Instead of nested ternary
# Use a map lookup! Cleaner! ✅

locals {
  env_map = {
    0 = "dev"
    1 = "staging"
    2 = "prod"
  }
}

resource "aws_s3_bucket" "buckets" {
  count = 3

  tags = {
    # Much cleaner!
    Environment = local.env_map[count.index]
  }
}