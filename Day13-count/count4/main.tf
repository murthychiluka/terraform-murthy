variable "environment_count" {
  default = 3
}

# Create 3 VPCs
resource "aws_vpc" "main" {
  count      = var.environment_count
  cidr_block = "10.${count.index}.0.0/16"

  tags = {
    Name = "vpc-${count.index}"
  }
}

# Create 3 subnets
resource "aws_subnet" "main" {
  count      = var.environment_count
  vpc_id     = aws_vpc.main[count.index].id
  cidr_block = "10.${count.index}.1.0/24"

  tags = {
    Name = "subnet-${count.index}"
  }
}

# Creates:
# vpc-0 with subnet using 10.0.0.0/16
# vpc-1 with subnet using 10.1.0.0/16
# vpc-2 with subnet using 10.2.0.0/16