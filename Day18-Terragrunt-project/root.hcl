# terragrunt.hcl (ROOT - at repo root)
# ──────────────────────────────────────
# Shared config for ALL environments!

# Remote state backend (write once!)
remote_state {
  backend = "s3"

  config = {
    bucket         = "murthyc-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Common inputs for ALL environments
inputs = {
  aws_region = "us-east-1"
  project    = "murthy-devops"
}