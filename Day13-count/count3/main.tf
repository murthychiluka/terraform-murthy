variable "create_bastion" {
  type    = bool
  default = true
}

# Create bastion only if variable is true
resource "aws_instance" "bastion" {
  count         = var.create_bastion ? 1 : 0
  ami           = "ami-0cca150d127c2216f"
  instance_type = "t3.micro"

  tags = {
    Name = "bastion-host"
  }
}

# create_bastion = true  → creates 1 bastion ✅
# create_bastion = false → creates 0 bastions ✅