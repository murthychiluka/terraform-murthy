# live/staging/vpc/terragrunt.hcl
# ────────────────────────────────

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

# Staging specific inputs
inputs = {
  environment = "staging"

  # Different CIDR for staging
  vpc_cidr = "10.1.0.0/16"

  public_subnets = [
    "10.1.1.0/24",
    "10.1.2.0/24"
  ]

  private_subnets = [
    "10.1.15.0/24",
    "10.1.16.0/24"
  ]

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]
}