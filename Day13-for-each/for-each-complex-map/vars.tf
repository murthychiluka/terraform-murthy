variable "envs" {
    default = {
        dev = {
            instance_type = "t3.micro"
            vpc_cidr = "10.0.0.0/16"
            subnet_cidr = "10.0.21.0/24"
        }
        qa = {
            instance_type = "t3.medium"
            vpc_cidr = "10.0.0.0/16"
            subnet_cidr = "10.0.22.0/24"

        }
        prod = {
            instance_type = "t3.small"
            vpc_cidr = "10.0.0.0/16"
            subnet_cidr = "10.0.23.0/24"
        }

    }
}