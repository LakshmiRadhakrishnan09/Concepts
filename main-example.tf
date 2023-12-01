provider "aws" {
    region = "us-east-1"
}


resource "aws_instance" "my_first_ec2_instance" {
    ami = "ami-id"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.web_sg.id] #Important: How to refer property of another resource

    #user_data = file("userdata.sh")  # Important: terraform has many buld in functions. File() is one of them
    #user_data = templatefile("userdata.sh.tpl" , {
    #    f_name = "ABC"
    #})  # Important: tAnothernbuild in function for template file
    user_data = <<EOF
 
    #!/bin/bash
    yum -y update
    ym -y install httpd
    MYIP = 'curl http://169.254.169.254/latest/meta-data/ip_v4'
    echo <h1>My Web Server. Private IP $MYIP</h1> >> /var/www/html/index.html
    service httpd start
    chkconfig httpd on

    EOF
    tags = {
      Name = "FirstEC2InstanceFromTF"
      CreatedBy = "Lakshmi"
    }

    lifecycle {  # Lifecyle. First create and then destroy. By default tf first destroy and then create.
      create_before_destroy = true
    }

    root_block_device {
     encrypted = var.env == "prod" ? true : false # Conditions
    }
}

resource "aws_instance" "db-server" {
    ami = ""
    instance_type = ""
    depends_on = [ aws_instance.my_first_ec2_instance ]  # Important: DB server will be provisioned only after web server is provisioned.
}

resource "aws_security_group" "web_sg" {
    name = "Web-Security-for-web-server"


    # Example for dynamic block
    dynamic "ingress" {
        for_each = ["80", "8080"]
        content {
            from_port = ingress.value
            to_port = ingress.value
            cidr_blocks = ["0.0.0.0/0"] #All
            protocol = "tcp"
        }
    }

    ingress {
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"] #All
        protocol = "tcp"
    }
    ingress {
        from_port = 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"] #All
        protocol = "tcp"
    }
    egress {
        from_port = 0 #All
        to_port = 0 #A;;
        cidr_blocks = ["0.0.0.0/0"] #All
        protocol = "-1" #All
    }

}

# Generate random password. Can be used as rds password
resource "random_password" "db_password" {
    length = 20
}

resource "aws_db_instance" "rds_instance" {
    instance_class = ""
    #password = random_password.db_password.result
    password = data.aws_ssm_parameter.rds_ssm_parameter.value
}

resource "aws_ssm_parameter" "rds_ssm_parameter" {
    name ="/prod/prd-mysql/password"
    value = random_password.db_password.result
    type = "SecureString"
}

//Read data
data "aws_ssm_pramater" "rds_ssm_parameter" {
    name = "/prod/prd-mysql/password"
    depends_on = [  aws_ssm_parameter.rds_ssm_parame]
}


resource "aws_secretmanager_secret" "rds_secret" {
    name = ""
}





# Outputs

output "my_sg_id" {
  value = aws_security_group.web_sg.id # output only one value.
}

output "my_sg_all_details" {
  value = aws_security_group.web_sg   # To get alll details // Dont use this
}

output "my_sg_all_details" {
  value = [aws_instance.web.id , aws_instance.db.id ]   # to output multiple values
}

output "my_rds_password" {
    value = data.aws_ssm_parameter.rds_ssm_parameter.value
    sensitive = true # Will not show valuei in console
}


# Json Encode Decode

resource "aws_secretmanager_secret_version" "rds_secret" {
    secret_id = aws_secretmanager_secret.rds_secret.id
    secret_string = jsonencode({
        rds_address = aws_db_instance.rds_instance.rds_address
        port = aws_db_instance.rds_instance.port
    })
}

output "rds_all" {
    value = jsondecode(aws_secretmanager_secret_version.rds_secret.secret_string)
} 



# Data Source

data "aws_region" "current"{}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "current" {}

output "my_aws_region" {
  value = data.aws_region.current.name
}

output "aws_account" {
    value = data.aws_caller_identity.current.account_id
}

output "availability_zones" {
    value = data.aws_availability_zones.current
}



data "aws_vpc" "my_delected_vpc" {   # data.aws_vpc.my_deleted_vpc.arn can read different atrributes and reference it at other places
    tags = {
        Name = "prod"   # Filter by tags. Search by tag
    }
}

resource "aws_subnet" "subnet1" {
    vpc_id = data.aws_vpc.my_deleted_vpc.id
    availability_zone = data.aws_availability_zones.current.names[0]
    tags = {
        Info = "AZ: ${data.aws_availability_zones.current.names[0]} in region ${data.my_aws_region.current.name}"
    }
} 

# To get ami
data "aws_ami" "latest_ubuntu" {   # u can reference by data.aws_ami.latest_ubuntu.id intsead of hardcoding. Works across region.
    owners = [""]
    most_recent = true
    filter {
      name = "name"
      values = ["ubuntu/images-*"]  # filter by a pattern
    }
}

#Variables

variable "env" {
    default = "prod"
}

variable "my_region" {    # refer this as var.my_region
    default ="us-east-1"
    description = "Region server is deployed"
    type = string # bool, number
}

variable "my_region" {} //nothing is mandatory. In this case use need to input. 
//If default value is provided,then that value is used. No user input required

variable "port_list" {    # refer this as var.my_region
    default = ["80", "443"]
    description = "Ports of server"
    type = list # list(any), list(string)
    sensitive = true # Will not show valuei in console. But it will there in state file
}

variable "tags" {
    type = map(string)
    description = "Default tags"
    default = {
        Name ="Lakshmi"
        Environment = "Prod"
    }
}

# var.tags
# merge(var.tags, {})
# var.tags["Environment"]

variable "allow_ports" {     # var.allow_ports["prod"] To read a map variable
    default = {
        "prod" = ["80", "8080" , "443"]
        "default_ports" = ["localhost"]
    }
}

# Variables support validation
variable "password" {
    description = "Enter password of length 10"
    type = string
    validation {
        condition = length(var.password) == 10 
        error_message = "Invalid password"
    }
}

#Local Variables

locals { # You can  have multiple locale blocks
    REG_INFO = "This is a long text with ${data.aws_availability_zones.names} and with size ${length(data.aws_availability_zones.names)}"
    LOCAL_VALUE = ""
}

locals {
    ANOTHER_LOCAL_VALUE = ""
}

resource "aws_vpc" "my_vpc" {
    tags = {
        Desc = local.REG_INFO # To use local variables
    }
}

# Condition: To conditionally execute a block. U need to make it dynamic

resource "aws_instance" "my_instanc2" {
    ami = ""
    instance_type = lookup(var.instance_type , var.env , "t3.micro") 

    # ebs_block_device {
    #   device_name = ""
    #   volume_size = ""
    # }

    dynamic "ebs_block_device"  {
        for_each = var.env == "prod" ? [true] : [] # Condition check. Empty if non-prod. For each will not execute.
        content {
          device_name = ""
          volume_size = ""
        }
      
    }


    dynamic "ingress" {
        for_each = lookup(var.allow_ports , var.env , var.allow_ports["default_ports"]) 
        # first parameter : variable name allow_ports(). 
        # second parameter: key that need to be kooedup. In this case "prod". 
        # If not found, use the third parameter.
        content {
            from_port = ingress.value
        }
    }

    
}

variable "instance_types" {
    default = [
        "t3.micro", "t1.micro"
    ]
}

#Count
resource "aws_instance" "my_instance" {
    count = 4
    instance_type = element(var.instance_types , count.index) # to get values from a list by position
    tags = {
        Name = "${count.index + 1}" 
    }
}

output "instance_ids" {
  value = aws_instance.servers[*].id  # to get all instances
}

#for_each; using count and index may result in replacement of resources when list is modified. 
#Count uses index (Server-1, Server-2)
#for_each works based on set. It use actual item in the list (Server-Web, Server-Db)

#In Terraform, dynamic blocks let you create nested blocks inside a resource based on a variable. 
#Instead of creating a resource for each item in a map, as the for_each attribute does, 
#dynamic blocks create nested blocks inside a resource for each item in a map or list.
#Use for each if u want multiple resoirces
#Use dynamic if u want to create multiple blocks inside a resource(eg: ingress).

variable "aws_users" { #list
    default = [ "user1", "user2"]
}

variable "server_settings" { #map
    default = {
        db = {
            instance-type = ""
        }
        web = {
            instance_type = ""
        }
    }
}

resource "aws_iam_user" "user" {
  for_each = toset(var.aws_users)
  name     = each.value   # Actual value not the index.
}

resource "aws_instance" "my_instance" {
    for_each = var.server_settings
    instance_type = each.value["instance_size"]
    tags = {
        Name  = "Server-${each.key}"
    
    }
}

output "prod_instance_id" {
  value = aws_instance.my_server["db"].id
}

output "instances_ids" {
  value = values(aws_instance.my_server)[*].id
}

# for in

output "users_unique_id_arn" {
  value = [
    for user in aws_iam_user.user :    # for in
    "UserID: ${user.unique_id} has ARN: ${user.arn}"
  ]
}