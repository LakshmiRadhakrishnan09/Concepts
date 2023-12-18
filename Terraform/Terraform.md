Automate Infrastructure provisioning

Main Concept
---------------

Resource
Output
Data
Variables
Remote Backend
Modules
Tf workspace
Tf state



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

To add a comment in tf file, use #

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
    nullable = false  # The default value for nullable is true. 
}

Step2: merge to tags. merge() is a tf function

tags = merge(var.tags, {
    Name = "ECS Instance 1"
})

Both output and variables support sensitive = true. But we can see the value on state file.
Setting a variable as sensitive prevents Terraform from showing its value in the plan or apply output, when you use that variable elsewhere in your configuration. Terraform will still record sensitive values in the state, and so anyone who can access the state data will have access to the sensitive values in cleartext. If you use a sensitive value as part of an output value then Terraform will require you to also mark the output value itself as sensitive, to confirm that you intended to export it.

Variables support validation

variable "password" {
    description = "Enter password of length 10"
    type = string
    validation {
        condition = length(var.password) == 10 
        error_message = "Invalid password"
    }
}

.tfvars files contain key value pair
aws_region    = "ca-central-1"
port_list     = ["80", "443", "8443"]

U can provide it as -var-file and it will ovevride default value.


Auto filling variables:
* Option 1: Command line . terraform apply -var="password=qwerty10" -var="instance_size=t3.small" # will ovevride default value provided
* Option 2: As env variable. export TF_VAR_<var_name> eg: TF_VAR_password=qwerty10 # will override default value
* usinf terraform.tfvars file . Name of variable and value eg: password=qwerty10    instance_size= "t3.micro" # This file will be taken automatically by terrafrm to substitute variable values. <>.auto.tfvars will also be taken automatically.
You can create multiple tfvars file ( eg: dev.tfvars, prod.tfvars). terraform apply -var-file="dev,tfvars"
* In tf cloud workspace(using -var or -varfile) approach.

Precedence
-var or -var-file ( Highest) . In the order they are provided
*.auto.tfvars or *.auto.tfvars.json in lexical order of filenames
terraform.tfvars.json ( .json has higher precedence)
terraform.tfvars
env variable
default

- Terraform uses the last value it finds, overriding any previous values. 
- Default parameter is optional
- Value of default should be a literal and cannot refer another configuration


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

    provisioner "remote-exec" { // will execute a script on resource(on cloud)
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

Lookup - to lookup a variable of type map
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

Similar to a Reusable functions that accepts input parameter. You pass different inputs to have different configuration. Creation logic remains the same.

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

tf init will initialize module.(Copy from source to local). Download the module.
We can use only the outputs exported by module.
To refer the module -> module.module_name.output_name

Each module need to be downloaded again. Even if the source is same.

Modules can use other modules.

source = "terraform-aws-modules/rds/aws" # module registerd in terraform. No need of absolute path. U can specify version.

# Terraform module for multiple region and account.
https://github.com/adv4000/terraform_certified/blob/master/Lab-36/main.tf

Providers are defined in client. Module refer to providers.

module "aws_server" {
    source = ""
    providers = {
            aws.root = aws  #LHS: what module accept. RHS : what is configured in client
            aws.prod = aws.PROD
            aws.dev = aws.DEV
    }
}

Module should accept these providers
https://github.com/adv4000/terraform_certified/blob/master/Lab-36/module_servers/main.tf

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws.root,
        aws.prod,
        aws.dev
      ]
    }
  }
}


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


Other commands
----------------

terraform taint <name_of_resource> : Recreate the resource. Similar to destroy and create. U need to do terraform apply after that. Tainted resource will be replaced.
terraform apply -replace <name_of_resource> : Instance will be replaced. Similar to taint. This is available only in lastest version.

To import existing resources:
* Option1: terraform import command
        Imports only the state. Not the configuration. 
        U need to define configuration block before u import.
        Not used with plan and apply
* Option2: terafform import block
        Support multiple resources
        Can be used with terraform plan and apply.
        Terraform processes the import block during the plan stage. Once a plan is approved, Terraform imports the resource into its state during the subsequent apply stage.
        You need to add a corresponding resource block to your configuration , or generate configuration for that resource.
* To generate configuration for resource
        Use generated-config-out   
        To generate configuration, run terraform plan with the -generate-config-out flag and supply a new file path. Do not supply a path to an existing file, or Terraform throws an error.
        If any resources targeted by an import block do not exist in your configuration, Terraform then generates and writes configuration for those resources in generated_resources.tf.   
        

To manage manually created resources. You import existing resources to manage them.
Assume already existing instance is i-07896
Create resource "aws_instance" "web" {} # Empty resource block
terraform import aws_instance.web i-07896
terraform import aws_s3.my_bucket bucket_name
terraform import <resource_type>.<ur_resource_name> <id_of_existing_resource>
After import if u do terraform apply , it will fail as parameters are missing. U need to set the resource exactly same as the existing one.

Terraform Import (v1.5)
to import use import block without import command

import {
    id = "sg-12345"   # Existing id
    to = aws.security_group.web
}

Run terraform init, terraform plan
terraform plan -generate-config-out=generated-sg.tf # it will generate code for you

Terraform workspace
---------------------
Same code. Different state. Duplicate resources. 
Use workspace only for **testing**. Never use it for prod, test, staging provisioning.

5 commands: terraform workspace show, list, new, select, delete

show: show the current workspace. By default , default workspace.
list: all workspaces.
new : create new. terraform workspace new <name_of_workspace>. This will create a new tf state folder. env:/<name_of_workspace>. Duplicate of state file in another place. If u use a different workspace, resources will be duplicated. Some aws resources cannot be provisioned with same name(You will get error). Will automatically switch to new one created. 
delete: terraform workspace delete <name_of_workspace>. You cannot delete a workspace with resource. -force will delete workspace. But resources will remain. Run terraform destroy and then delete workspace. You need to switch to another workspace(You cannot be in the workspace u want to delete)

${terraform.workspace} : holds the workspace name. Use it to identify the workspace used.

Terraform state
------------------

terraform state show, list, pull - No changes to state
terraform state rm, mv, push - Danger commands. Change the state. Do proper review.

show: show configuration of a resource. 
    terraform show state <resource_name>
list: show all resources that exist in state file
    lists resources managed by state. Only resource references. eg: aws_instance.web
pull: pull state file to local
rm: completely remove resource from terraform. 
mv: move resource from one state to another state!!
push: ovevride remote state.

State management commands take a timestamped backup of state.


Updating State file - Don't change lineage. Change serial to next version.

Scanerio: You want to rename a tf resource reference. You dont want to change the actual running resource.
Eg: aws_instance.myweb to aws_instance.web1.

Option1: Manually edit the state file . Change serial and push.
Option2: terraform state mv aws_instance.myweb aws_instance.web1. Will rename the resource. If u rename the resource in ur code and do a terraform apply it will say "no change".


We may have different state files for your infra(One per  tf folder). But do not use different workspace.

When u refactor if u want to move resources from one state to another(one folder to another). From a single infra to prod infra and staging infra. Move aws_instance prod from infra to prod folder.

Step1: Move the main.tf.
Step2: Extract existing resources to a local tf state file. Remove the resource and add to local state.
terraform state mv -state-out="terraform.tfstate" aws_eip.prod-ip1 aws_eip.prod-ip1 # You can rename also. Last paramater is the new name.
Step3: We can move multiple resoures. It appends to terraform.tfstate file.
Step4: Copy terraform.state. Update new tf state backend /prod
Step5: terraform init. "Do you want to copy existing state to the new backend?". Since you can local tfstate and there is a new backend configured. Once y select "yes"., local state will be empty.
Step5: terraform apply. No change to infra.

If remove state already exist( Not a fresh state)-> 
Step 1: terraform state pull > terraform.tfstate.
Step2: Move t to the folder u want to extract. Execute terraform state mv -state-out="terraform.tfstate" <existing_resource_name> <new_resource_name>
Step3: Place state file back to new required folder. 
Step4: Add code for moved infra
Step5: Tfstate has existing and moved resources. Do terraform state push terraform.state.
Step6. terraform apply. No change

To do in a loop

terraform state list | grep aws_eip.stag
for x in $(terraform state list | grep aws_eip.stag); do terraform state mv -state-out="terraform.tfstate" $x $x


terraform show <resource_address>: state of single resource
terraform state list: list all resources
terraform pull: This command downloads the state from its current location, upgrades the local copy to the latest state file version that is compatible with locally-installed Terraform, and outputs the raw format to stdout.
terraform state rm <resource_address>:  You can use terraform state rm in the less common situation where you wish to remove a binding to an existing remote object without first destroying it, which will effectively make Terraform "forget" the object while it continues to exist in the remote system. Terraform will no longer be tracking the corresponding remote objects. Resource will continue to exist in remote system. A subsequent terraform plan will include an action to create a new object for each of the "forgotten" instances. 
terraform state mv <resource_address> : You can use terraform state mv in the less common situation where you wish to retain an existing remote object but track it as a different resource instance address in Terraform, such as if you have renamed a resource block or you have moved it into a different module in your configuration.

More Commands
--------------

terraform apply target=aws_instance.web # Check only state of that resource and dependent resources. Do not check for other resources. Will not refresh state of other resources.
terraform apply -auto-approve      # Do not ask for approval.


terraform validate  # check for syntax issues in code.

terraform output  # show outputs
The terraform output command is used to extract the value of an output variable from the state file. ( You can get the outputs not defined for your code)

terraform output [options] [NAME]
With no additional arguments, output will display all the outputs for the root module. If an output NAME is specified, only the value of that output is printed. When using the -json or -raw command-line flag, any sensitive values in Terraform state will be displayed in plain text. For more information, see Sensitive Data in State.

terraform show # show all configuration.Also output.

terraform show [options] [file]
You may use show with a path to either a Terraform state file or plan file. If you don't specify a file path, Terraform will show the latest state snapshot.

The terraform show command is used to provide human-readable output from a state or plan file. This can be used to inspect a plan to ensure that the planned operations are expected, or to inspect the current state as Terraform sees it.

If you've updated providers which contain new schema versions since the state was written, the state needs to be upgraded before it can be displayed with show -json. If you are viewing a plan, it must be created without -refresh=false. If you are viewing a state file, run terraform refresh first.

terraform console # Run terraform functions upper(), max()

terraform refresh # update state file with current configuration(what is deployed).

force-unlock : This command removes the lock on the state for the current configuration. Manually unlock the state for the defined configuration.

To destroy resources
terraform apply -destroy
or
terraform destroy : Will ask "Do you really want to destroy all resources?"

terraform plan -destroy
terraform state rm * . This will not delete the remote resource.


Terraform logs
----------------

export TF_LOG="hello"  # default TRACE level
TRACE, DEBUG, INFO, WARN, ERROR

export TF_LOG=INFO

export TF_LOG_PATH=terraform.logs

Terraform Cloud
-------------------
SASS Solution ( https://app.terraform.io)

You dont need to install cli. Terraform Cloud is free. Need to pay for Sentinel Policy.
You need to create an account. 

Who need tf cloud?
- For big team
- remote execution of tf plan, apply and detroy
- Integration with git
- Store remote state
- Registry of tf modules
- Notification to webhooks
- Different level of access
- Sentinel Policy
- Cost estimation. Can be used with sentinel policy to restrict privisioning of higher cost.


Create an organization
Create a workspace
Set Env Variables
    Set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
Configure Terraform Variables   

Settings page -> u can set tf version.

Terraform Enterprise
--------------------------

Self hosted distribution of terraform cloud. Enterprise self hosted solution. Managed by organizations.
It is paid
You control users and everything.

Global Variables
-----------------
To share variables between folders
1. Create a module. Define outputs with variable values
outputs "instance_size" {
    value = "T3.micro"
}
2. Use the module to get the variable value -> module.global.instance_size
module "global" {
    source ="./global_vars"
}


Dependency Lock file
------------------------
terraform.lock.hcl

Created when u run terraform init. To record provider selections. Include this file in version control repository. 
Do not edit manually.

terraform init -upgrade

terraform refresh is deprecated. Not recommened to use.





