variable "instance_names" {
  default = ["frontend", "backend", "database"]
}

resource "aws_instance" "servers" {
  count         = length(var.instance_names)
  ami           =  "ami-0cca150d127c2216f"
  instance_type = "t3.micro"

  tags = {
    # Uses index to get name from list
    Name = var.instance_names[count.index]
  }
}

# Creates:
# frontend  (index 0)
# backend   (index 1)
# database  (index 2)