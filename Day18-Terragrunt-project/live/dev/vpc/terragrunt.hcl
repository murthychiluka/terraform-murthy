# live/dev/vpc/terragrunt.hcl
# ────────────────────────────
# Dev environment config

# Include root config
include "root"{
  path = find_in_parent_folders()
}

# Point to VPC module
terraform {
  source = "../../../modules/vpc"
}

# Dev specific inputs
inputs = {
  environment = "dev"

  # Small CIDR for dev
  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]

  private_subnets = [
    "10.0.13.0/24",
    "10.0.14.0/24"
  ]

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]
}