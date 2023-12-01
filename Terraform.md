Automate Infrastructure provisioning

terraform -version

Need tf cli. Check for env variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.

terraform init : Read all tf files in the folder. Check which providers are in use. It download the provider(aws). Downloads all plugins and create a .terraform file. When u push the code gitignore .terraform folder.

terraform plan : Will create lock file and state files.

terraform apply: Will do a plan first and the do apply


What will happen if we run terraform apply two times?
It wont create two resources. It checks the state file and identifies that there is no change to previous state. So it wont apply any change.


Refeshing state happens while - Tf apply and tf plan and tf destroy

~ means Update in place means it wont replace. 1 to update

-/+ means destroy and then create new replacement. 1 to add. 1 to destroy. Tf plan will highlight which parameter caused a "forces replacement".

Based on scenario terraform decide whether a replacement is needed. A change in keypair may result in terminating the instance and creating a new instance(replcament). A change in instance type may just need a stop and start(update in place).



Terraform, compares state file and your code. It will not check with actual resource on cloud. So it is very important to keep ur state file up to date.


To destroy a resource - you can comment the code or run terraform destroy

Terraform destroy: Destroy everything in tf file.

# To put comment

Name of the file doesnt matter.

Order in file doesnt matter.

Resources may get provisioned in parallel also. You can control using depends_on option.

Important: TF state files may have passwords in plain text. Create password using random_password. Set it to SSM parameter. read it using a data block and set it to rds instance. In all these cases (multiple places) password is stored in state file.

name-prefix : provide a prefix. Tf will create a suffix and attch to name


resource "aws_default_subnet" "default_subnet" {
    availability_zone = "us-east-1
} # Special resource. Tf will not create it. It behaves differently from normal resources. To manage the resource. 

Add default tags to all resources

Step1: Define variable
variable "tags" {
    type = map(string)
    description = "Default tags"
    default = {
        Name ="Lakshmi"
        Enviornement = "Prod"
    }
}

Step2: merge to tags. merge() is a tf function

tags = merge(var.tags, {
    Name = "ECS Instance 1"
})

Both output and variables support sensitive = true. But we can see the value on state file.


Variables support validation

variable "password" {
    description = "Enter password of length 10"
    type = string
    validation {
        condition = length(var.password) == 10 
        error_message = "Invalid password"
    }
}


Auto filling variables:
* Option 1: Command line . terraform apply -var="password=qwerty10" -var="instance_size=t3.small" # will ovevride default value provided
* Option 2: As env variable. export TF_VAR_<var_name> eg: TF_VAR_password=qwerty10 # will override default value
* usinf terraform.tfvars file . Name of variable and value eg: password=qwerty10    instance_size= "t3.micro" # This file will be taken automatically by terrafrm to substitute variable values. <>.auto.tfvars will also be taken automatically.
You can create multiple tfvars file ( eg: dev.tfvars, prod.tfvars). terraform apply -var-file="dev,tfvars"

Precedence
-var or -var-file ( Highest)
*.auto.tfvars or *.auto.tfvars.json in lexical order of filenames
terraform.tfvars.json ( .json has higher precedence)
terraform.tfvars
env variable
default

Executing local commands using provisioner. Will execute on local machine
resource "null_resource" "command1" {
    provisioner "local-exec" {
            command = "echo Terraform >> log.txt"
    }
}

resource "null_resource" "command2" {
    provisioner "local-exec" {
            interpreter = ["python" , "-c"]
            command = "print('hello')"
    }
}

resource "null_resource" "command2" { //if u run tf again it will not execute. Execute only once if no change.
    provisioner "local-exec" {
            command = "echo $NAME"
            environement = {
                NAME = "Lakshmi"
            }
    }
}

resource "aws_instance" "my_instance"{
    instance_type = "t3.micro"
    provisioner "local-exec" { //provisioner can be part of a resource provision. It is executed on local machine. Is executed after resource is provisioned 
        command ="echo ${aws_instance.my_instance.id}"
    }

    provisioner "remote-exec" { // will execute on resource(on cloud)
        inline = [
            "mkdir /home/ec2-user/terraform",
            "cd ",
            "touch ..."
        ]
        connection {
            type ="ssh"
            user=""
            host=""
            privateKey=""

        }
    }
}

Lookup
variable "server_size" {
    default = {
        "prod" = "t3.large"
        "dev" = "t3.micro"
    }
}

var.server_size["prod"]
lookup(var.server_size, "prod", "t3.nano") # Can use a default value.

Deploy to multiple region
To support multi-region deployment, you can include multiple configurations for a given provider by including multiple provider blocks with the same provider name, but different alias meta-argument for each additional configuration.

provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  region = "eu-south-1"
  alias  = "EUROPE"
}

provider "aws" {
  region = "ap-northeast-1"
  alias  = "ASIA"
}

data "aws_ami" "europe_latest_ubuntu20" {
  provider    = aws.EUROPE
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

To deploy to multiple accounts

provider "aws" {
  region = "ca-central-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "DEV"

  assume_role {
    role_arn = "arn:aws:iam::639130796919:role/TerraformRole"
  }
}

provider "aws" {
  region = "ca-central-1"
  alias  = "PROD"

  assume_role {
    role_arn = "arn:aws:iam::032823347814:role/TerraformRole"
  }
}

Terraform Remote State
----------------------------

Terraform supports remote backends : artifactory, etcd, http, s3, azurerm, gcs,  consul...

# To save to S3 remote backend
terraform {
    backend "s3" {
        bucket = "tf-terraform"
        key ="dev/network/terraform.tfstate"
        region = "us-east-1"
    }
}

If u need to refer to resources created by a different tf (different layes - network and web), u need to read from remote backend. Assume u have two folders - Layer1-network and Layer2-web. If web(ECS) want to know the VPC id created by Layer 1, then

# To read remote backend state

data "terraform_remote_state" "vpc" {
    backend =  "s3"
    config = {
        bucket = "tf-terraform"
        key ="dev/network/terraform.tfstate"  # Key of the remote tf state file
        region = "us-east-1"
    }
}

You can refer this as
vpc_id = data.terraform_remote_state.vpc.outputs.my_vpc_id # Important - Only output variables can be referenced.

Modules
----------------------

Similar to a Reusable functions that accepts input parameter. You pass different inputs to have different configuration. Create logic remains the same.

Important: Module should not have provider block and region block.

Folder Structure
- modules
    - aws-network
        - main.tf : Creates resoures usinf default variables
        - variables : Inputs that can be overriden
        - outputs: That can be used by clients

- projectA
    - main.tf
        - use the module to provision resource. Can override Inputs.
            
- projectB
    # allows reusing code between multiple projects.



Main Concept
---------------

Resource
Output
Data
Variables
Remote Backend
Modules

Concepts:
---------------

Dynamic block : To created multiple blocks in a resource using for_each
Lifecycle: By deafult, tf destroy resource and then create a new one. This results in downtime. aws_ecs_instance supports lifecycle property. set create_before_destroy to true.
Depends On: Resource will be provisioned only after depends_on resources are provisioned
Outputs : Can print only one value. Can use a list of values to output multiple values.
Data(data source) : To read data and set as value for some properties. Outputs cannot be used to set data for resources. Example, u want to read aws secret manager secret and set to rds password. You need to read the value using data block and then use data.<resource_name>.value as password.
Data Source: To read data from resources that are not provisioned by terraform ( not available in tf state). Get information about provisioned resources. So instaed of hardcoding an already provisioned resource id in ur code, u can read it using "data" block and use it.
Variables: Anything that changes frequently(for example region)
Local Variables: Define local variables. You can refer a local in another local.
LOcal and Remote execute

--------
Advanced
---------

Conditions: For condition checks. To conditionally execute a block of code
Lookup: To read values from a variable of type map.
Loops: Count, for_each, for_in

--------------------
Certification Syntax
--------------------


To refer another resource

resource_key.resource_name.resource_property Eg: aws_ec2_instance.my_instance.id. Do not use "" when u reference other resources.

To read information about resources

data "aws_vpc" "my_delected_vpc" {   # data.aws_vpc.my_deleted_vpc.arn can read different atrributes and reference it at other places
    id = var.vpc_id
    tags = {
        Name = "prod"   # Filter by tags. Search by tag
    }
}

variable "my_region" {    # refer this as var.my_region
    default ="us-east-1"
    description = "Region server is deployed"
    type = string # bool, number
}









