variable "aws_region" {
 default = "ap-south-1"
}
variable "vpc_cidr" {
 default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
 default = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
 default = "10.0.2.0/24"
}
variable "instance_type" {
 default = "t2.micro"
}
variable "db_username" {
 default = "admin"
}
variable "db_password" {
 default = "password123!"
}
variable "domain_name" {
 description = "Domain name (optional)"
 default = ""
}
variable "key_name" {
 default = "mykey"
}
