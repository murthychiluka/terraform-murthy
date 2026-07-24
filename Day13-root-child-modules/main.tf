module "vpc" {
  source       = "./modules/vpc"
  cidr_block   = var.cidr_block
  subnet_1_cidr  = var.subnet_1_cidr
  subnet_2_cidr = var.subnet_2_cidr
  az1           = var.az1
  az2           = var.az2
}

module "ec2" {
  source        = "./modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_1_id   = module.vpc.subnet_1_id
}

module "rds" {
  source         = "./modules/rds"
  subnet_1_id      = module.vpc.subnet_1_id
  subnet_2_id      = module.vpc.subnet_2_id
  instance_class = var.instance_class
  db_name        = var.db_name
  db_user        = var.db_user
  db_password    = var.db_password
}

module "s3" {
    source = "./modules/s3"
    bucket = var.bucket
  

}

# module "lambda" {
#     source = "./modules/lambda"
# }
