# live/production/vpc/terragrunt.hcl
# ────────────────────────────────────

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

# Production specific inputs
inputs = {
  environment = "production"

  # Larger CIDR for production
  vpc_cidr = "10.2.0.0/16"

  # More subnets in production
  public_subnets = [
    "10.2.1.0/24",
    "10.2.2.0/24",
    "10.2.3.0/24"
  ]

  private_subnets = [
    "10.2.4.0/24",
    "10.2.5.0/24",
    "10.2.6.0/24"
  ]

  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}