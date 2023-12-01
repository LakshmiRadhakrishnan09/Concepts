# modules/aws_network
#https://github.com/adv4000/terraform_certified/blob/master/Lab-26/modules/aws_network/main.tf
# Provision:
#  - VPC
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give Internet access from Private Subnets

# Module has default variables which can be overriden by clients

#Module best practice
# Create lot of variables
# Create lot of ouputs
# Modules should be in seperate folder
# Module should not have provider block
variable "env" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

# Resources configured by module. 

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${var.env}-vpc" })
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.env}-igw" })
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.env}-public-${count.index + 1}" })
}



# Project A

#Refer the modules. Use as is without any overriding. If not provided it use modules default variable values
module "my_vpc_default" {   #
    source = "../modules/aws_network"
}

#Use the modules by overriding variables(Module Input).
module "my_vpc_staging" {
    source               = "../modules/aws_network"
    env                  = "staging"
    vpc_cidr             = "10.100.0.0/16"
    public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
    private_subnet_cidrs = []                   
}

# Output only those output by module( Module output)
output "my_vpc_id" {
  value = module.my_vpc_default.vpc_id
}