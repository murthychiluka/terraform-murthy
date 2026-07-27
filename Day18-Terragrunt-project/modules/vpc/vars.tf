# modules/vpc/variables.tf

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones"
}