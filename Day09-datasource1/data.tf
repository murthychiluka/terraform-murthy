data "aws_subnet" "name" {
    filter {
        name   = "tag:Name"
        values = ["Public-1b"]
    }
}
data "aws_ami" "name" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}