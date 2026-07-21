resource "aws_instance" "dev" {
    ami = "ami-01edba92f9036f76e"
    instance_type = "t2.medium"
      tags = {
        "Name" = "dev"
      }

#    lifecycle {
#      create_before_destroy = true
#     }
   lifecycle {
    prevent_destroy = true
   }
#    lifecycle {
#      ignore_changes = [ tags ]
#    }
}
