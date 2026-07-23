#create vpc per env
resource "aws_vpc" "envs" {
    cidr_block = each.value.vpc_cidr
    for_each = var.envs
    tags = {
      name = "${each.key}-vpc"
    }
}
resource "aws_subnet" "envs" {
    vpc_id = aws_vpc.envs[each.key].id
    cidr_block = each.value.subnet_cidr
    for_each = var.envs
    tags = {
      name = "${each.key}-subnet"
    }
}
#Create EC2 per environment
resource "aws_instance" "envs" {
    ami =  "ami-0cca150d127c2216f"
    for_each = var.envs
    instance_type = each.value.instance_type
    subnet_id = aws_subnet.envs[each.key].id

    tags = {
      name = "${each.key}-server"
      environment= each.key
    }
}
     
   output "environment_ips" {
  value = {
    for env, instance in aws_instance.envs :
    env => instance.public_ip
  }
}
 
     
    


    
