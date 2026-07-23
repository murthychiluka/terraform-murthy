variable "instances" {
  default = {
    "frontend" = "t3.micro"
    "backend"  = "t3.small"
    "database" = "t3.medium"
  }
}

resource "aws_instance" "servers" {
  for_each      = var.instances
  ami           =  "ami-0cca150d127c2216f"
  instance_type = each.value  # t2.micro, t2.small, t2.medium

  tags = {
    Name = each.key  # frontend, backend, database
  }
}

# Creates:
# aws_instance.servers["frontend"] → t2.micro
# aws_instance.servers["backend"]  → t2.small
# aws_instance.servers["database"] → t2.medium