## Terraform

Terraform is an immutable, declarative, Infrastructure as Code provisioning language based on Hashicorp Configuration Language, or optionally JSON.
Automate Infrastructure provisioning. It is not a configuration management tool.
Configuration management tool like Chef and Puppet install and manage software on a machine that already exists. Terraform is not a configuration management tool, it is an Infrastructure provisioning tool to bootstrap and initialize resources.

There is no Terraform binary for AIX. Terraform is available for:- macOS, Windows, Linux, FreeBSD, OpenBSD, and Solaris.

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

The .tfstate and .tfvars might contain sensitive data and should be added in .gitignore file

depends_on is an optional argument for declaring output value, not for declaring input variable.


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

null_resource has been renamed to terraform_data in Terraform v1.4.x and later version

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

provisioner "local-exec" {
  when    = destroy
  command = "echo 'Destroy-time provisioner'"
}

destroy provisioner is executed "before" the resource is destroyed.

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

To copy a source module
Given a version control source, terraform init -from-module={MODULE-SOURCE} can serve as a shorthand for checking out a configuration from version control and then initializing the working directory for it.

Whenever you add a new module to a configuration, Terraform must install the module before it can be used. Both the **terraform get** and **terraform init** commands will install and update modules.

A module that has been called by another module is often referred to as a child module. The module that calls a module is called parent module.

Module arguments - source, version, depends_on, count, for_each, providers.

When specifying a source for a private registry, the correct Syntax is <HOSTNAME>/<NAMESPACE>/<NAME>/<PROVIDER> e.g. app.terraform.io/example_corp/vpc/aws. It is different than the public registry because it includes the <HOSTNAME> field.

to refer modules from Public Terraform Registry use <NAMESPACE>/<NAME>/<PROVIDER>. eg: hashicorp/consul/aws


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
        terraform import [options] <ADDRESS> <ID>
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

5 commands: terraform workspace show, list, new, **select**, delete

show: show the current workspace. By default , default workspace.
list: all workspaces.
new : create new. terraform workspace new <name_of_workspace>. This will create a new tf state folder. env:/<name_of_workspace>. Duplicate of state file in another place. If u use a different workspace, resources will be duplicated. Some aws resources cannot be provisioned with same name(You will get error). Will automatically switch to new one created. 
delete: terraform workspace delete <name_of_workspace>. You cannot delete a workspace with resource. -force will delete workspace. But resources will remain. Run terraform destroy and then delete workspace. You need to switch to another workspace(You cannot be in the workspace u want to delete)

${terraform.workspace} : holds the workspace name. Use it to identify the workspace used.

Terraform state
------------------

Default location : the current directory where terraform is executed.

terraform state show, list, pull - No changes to state
terraform state rm, mv, push - Danger commands. Change the state. Do proper review.

show: show configuration of a resource. 
    terraform state show <resource_name>
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

Running a terraform state list does not cause Terraform to refresh its state. This command simply reads the state file but it will not modify it.

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
terraform refresh is deprecated. Not recommened to use.

force-unlock : This command removes the lock on the state for the current configuration. Manually unlock the state for the defined configuration.

terraform force-unlock

To destroy resources
terraform apply -destroy
or
terraform destroy : Will ask "Do you really want to destroy all resources?"

terraform plan -destroy
terraform state rm * . This will not delete the remote resource.

terraform fmt
To see the diff - terraform fmt -diff.
terraform fmt -diff command display diffs of formatting changes
terraform fmt -check -recursive  # format current directory and subdirectory


terraform validate -json

terraform refresh is an alias of terraform apply -refresh-only -auto-approve. But this is risky. Alternatily use terraorm apply -refresh-only.
Automatically applying the effect of a refresh is risky. If you have misconfigured credentials for one or more providers, Terraform may be misled into thinking that all of the managed objects have been deleted, causing it to remove all of the tracked objects without any confirmation prompt.

terraform plan -out=dev.tfplan

The command terraform apply -parallelism=20 limits the number of concurrent operation to 20 as Terraform walks the graph. default is 10.

Terraform logs
----------------

export TF_LOG="hello"  # default TRACE level
TRACE, DEBUG, INFO, WARN, ERROR

export TF_LOG=INFO

TF_LOG : Enabling this setting causes detailed logs to appear on **stderr**


export TF_LOG_PATH=terraform.logs
Note that even when TF_LOG_PATH is set, TF_LOG must be set in order for any logging to be enabled.

Setting TF_LOG to JSON outputs logs at the TRACE level or higher, and uses a parseable JSON encoding as the formatting.



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
.terraform.lock.hcl

Created when u run terraform init. To record provider selections. Include this file in version control repository. 
Do not edit manually.

The dependency lock file is always named .terraform.lock.hcl, and this name is intended to signify that it is a lock file for various items that Terraform caches in the .terraform subdirectory of your working directory. Terraform automatically creates or updates the dependency lock file each time you run the terraform init command. 

You should include this file in your version control repository so that you can discuss potential changes to your external dependencies via code review, just as you would discuss potential changes to your configuration itself.


terraform init -upgrade

terraform providers lock ( normally invoked as part of terraform init)

The 'terraform providers lock' consults upstream registries (by default) in order to write provider dependency information into the dependency lock file.

The 'terraform providers lock' will analyze the configuration in the current working directory to find all of the providers it depends on, and it will fetch the necessary data about those providers from their origin registries and then update the dependency lock file to include a selected version for each provider and all of the package checksums that are covered by the provider developer’s cryptographic signature.


terraform providers mirror: downloads the providers required for the current configuration and copies them into a directory in the local filesystem.

Terraform state
--------------------

Terraform stores information about your infrastructure in a state file. This state file keeps track of resources created by your configuration and maps them to real-world resources.Terraform compares your configuration with the state file and your existing infrastructure to create plans and make changes to your infrastructure(terraform refresh).

Terraform automatically performs a refresh during the plan, apply, and destroy operations. All of these commands will reconcile state by default, and have the potential to modify your state file.

The terraform refresh command updates the state file when physical resources change outside of the Terraform workflow.

1. Using tf u created a ECS Instance
2. U deleted ECS Instance using AWS Console
3. tf refresh
        Deleted resource will not be in state. It shows actual infrastructure
4. tf plan/apply
        Will add back the resource.

State locking happens automatically on all operations that could write state. You won’t see any message that it is happening. If state locking fails, Terraform will not continue. You can disable state locking for most commands with the -lock flag but it is not recommended.

Not all backends support locking. Following Terraform backend types supports state locking:- local, remote, azurerm, consul, cos, gcs, http, kubernetes, oss, pg, and s3

Terraform Cloud
--------------------

Terraform Cloud manages plans and billing at the "organization level."
Small teams can use most of Terraform Cloud's features for free, including remote Terraform execution, VCS integration, the private module registry.

Free organizations are limited to five active members.

Terraform Cloud has 4 Pricing Tiers:
Free : Upto 500 resources per month. Free
Standard : Enterprise support Included. Some are free.
Plus : Enterprise support Included. Paid
Enterprise : Enterprise support Included. Paid

SSO is supported for Free tier now.

Audit Logging, Drift detection , Sentinel : For Plus and Enterprise tiers
Application Logging and Log forwarding, Runtime metrics(Prometheus) : Only for Enterprise


Remote State
---------------

Remote state is implemented by a backend(S3 or gcp or ...) or by Terraform Cloud, both of which you can configure in your configuration's root module.

With a fully-featured state backend, Terraform can use remote locking as a measure to avoid two or more different users accidentally running Terraform at the same time, and thus ensure that each Terraform run begins with the most recent updated state.


Terraform Backend
----------------------
Each tf configuration has a backend.
Backend defines - where is the state file and where the operations are executed.
Some backend support multiple workspaces.



Local Backend : Stores state files, lock that state and perform operations locally. It will not store providers.
The path and workspace_dir are two optional configuration supported by local backend.
path - (Optional) The path to the tfstate file. This defaults to "terraform.tfstate" relative to the root module by default.
workspace_dir - (Optional) The path to non-default workspaces.

A terraform configuration can only provide one backend block.

terraform {
  backend "local" {
    path = "relative/path/to/terraform.tfstate"
  }
}

A backend block cannot refer to named values (like input variables, locals, or data source attributes).

You can supply backend ocnfigurations using as part of terraform **init**:
terraform init -backend-config=PATH or terraform init -backend-config="KEY=VALUE"

local backend type doesn’t support remote state storage; artifactory and etcd backend types doesn’t support state locking.

Remote Backend : Execute operations on terraform cloud

The remote backend is unique among all other Terraform backends because it can both store state snapshots and execute operations for Terraform Cloud's CLI-driven run workflow. It used to be called an "enhanced" backend.

We recommend using environment variables to supply credentials and other sensitive data. If you use -backend-config or hardcode these values directly in your configuration, Terraform will include these values in both the .terraform subdirectory and in plan files. This can leak sensitive credentials.

Terraform writes backend configuration as plain text in .terraform/terraform.tfstate


Terraform Workspace
-----------------------
workspace is like renaming you state file. 

For local state, Terraform stores the workspace states in a directory called terraform.tfstate.d.

For remote state, the workspaces are stored directly in the configured backend. 

The state file belongs to a workspace.
Some backends support multiple named workspaces.

You can have as S3 backend. You can have multiple workspaces associated to this backend.

You cannot delete default workspace.

Terraform stores the current workspace name locally in the ignored .terraform directory. This allows multiple team members to work on different workspaces concurrently. Workspace names are also attached to associated remote workspaces in Terraform Cloud. 

Remote backend can work with either a single remote Terraform Cloud workspace, or with multiple similarly-named remote workspaces (like networking-dev and networking-prod). The workspaces block of the backend configuration determines which mode it uses.

# Using a single workspace:
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "company"

    workspaces {
      name = "my-app-prod"
    }
  }
}

# Using multiple workspaces:
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "company"

    workspaces {
      prefix = "my-app-"
    }
  }
}


Terraform Cloud Workspace
----------------------------

Terraform Cloud organizes infrastructure using workspaces, but its workspaces act more like completely separate working directories. Each Terraform Cloud workspace has its own Terraform configuration, set of variable values, state data, run history, and settings.

When you integrate Terraform CLI with Terraform Cloud, you can associate the current CLI working directory with one or more remote Terraform Cloud workspaces. Then, use the terraform workspace commands to select the remote workspace you want to use for each run.


Providers
------------------

Terraform configurations must declare which providers they require so that Terraform can install and use them.

```
provider "google" {
  project = "acme-app"
  region  = "us-central1"
}
```


alias and version: two provider arguments defined by terraform and available for all providers.

alias: using same provider with different configuration for different resources. Eg: configure aws provider multi-region.

version: not recommended. use provider requirements instaed.

A provider block without an alias argument is the default configuration for that provider. 

Each Terraform module must declare which providers it requires, so that Terraform can install and use them. Provider requirements are declared in a required_providers block. 

```
terraform {
  required_providers {
    mycloud = {     # local name
      source  = "mycorp/mycloud"  # global source address
      version = "~> 1.0"
    }
  }
}
```
```

provider "mycloud" {

}
```

Users of a provider can use any local name. 
Whenever possible use providers preferred local name. For example harshicorp/aws use aws as local name. Then you can omit provider in your resource configuration. (If a resource doesn't specify which provider configuration to use, Terraform interprets the first word of the resource type as a local provider name.)

resource "aws_instance" {  # first word "aws" is considered as provider.

}


source -> [<HOSTNAME>/]<NAMESPACE>/<TYPE>
hostname by default is registry.terraform.io

required_providers defines the list or providers necessary for deploying resources. This can be a single one, or multiple including aws, azurerm, google, kubernetes, alicloud and a dozen others. 

If you don't declare a particular provider(as required provider), Terraform will create an implicit required_providers declaration assuming that you mean a provider in the hashicorp/ namespace, which makes it seem as though required_providers is only for third-party providers. For third paty privider , required_provider is mandatory. 

Syntax
--------

Indent two spaces for each nesting level.


Resource Graph
-------------------
https://developer.hashicorp.com/terraform/internals/graph#building-the-graph

Terraform builds a dependency graph from the Terraform configurations, and walks this graph to generate plans, refresh state, and more. 

Resource Node: The configuration, diff, state, etc. of the resource under change is attached to this node.
Provider Configuration Node

terraform graph


1. Resource nodes are added. If a diff (plan) or state is present, that meta-data is attached to each resource node.
2. Resources are mapped to provisioners if they have any defined. 
3. Create edges between node, (uses depends_on) 
4. If a state is present, any "orphan" resources are added to the graph. Orphan resources are any resources that are no longer present in the configuration but are present in the state file. Orphans never have any configuration associated with them, since the state file does not store configuration.
5. Resources are mapped to providers.
6. References to resource attributes are turned into dependencies from the resource with the interpolation to the resource being referenced.
7. Create a root node.
8. If a diff is present, traverse all resource nodes and find resources that are being destroyed. These resource nodes are split into two: one node that destroys the resource and another that creates the resource (if it is being recreated). The reason the nodes must be split is because the destroy order is often different from the create order, and so they can't be represented by a single graph node.
9. Validate the graph has no cycles and has a single root.

Selecting Plugins
---------------

After locating any installed plugins, 'terraform init' compares them to the configuration's version constraints and chooses a version for each plugin as follows:

If any acceptable versions are installed, Terraform uses the newest installed version that meets the constraint (even if the Terraform Registry has a newer acceptable version).
If no acceptable versions are installed and the plugin is one of the providers distributed by HashiCorp, Terraform downloads the newest acceptable version from the Terraform Registry and saves it in a subdirectory under .terraform/providers/.
If no acceptable versions are installed and the plugin is not distributed in the Terraform Registry, initialization fails and the user must manually install an appropriate version.

To publish a module to public registry

- module must be on GitHub and must be a public repo
- at least one release tag
- naming convention terraform-PROVIDER-Name eg: terraform-google-vault

The requirements for Publishing to Terraform Cloud Private Registry is same as publishing to Terraform Public Registry except that module repository can be on your configured VCS providers in case of private registry whereas it must be public Github repo in case of public registry

Sentinel Imports
------------------

Terraform Cloud provides four imports to define policy rules for the plan, configuration, state, and run associated with a policy check.

- tfplan
- tfconfig : Set of .tf files.
- tfstate
- tfrun

Enforcement levels

- Advisory: Will not fail the run
- Soft Mandatory : Fails the run. But u can override and continue. User with  'Manage Policy Overrides permission'. the run pauses in the Policy Override state.
- Hard Mandatory : Cannot override.


Version Constraint

version = ">= 1.2.0, < 2.0.0"

~>: Allows only the rightmost version component to increment. This format is referred to as the pessimistic constraint operator. 
~> 1.0.4: Allows Terraform to install 1.0.5 and 1.0.10 but not 1.1.0.
~> 1.0.4 means >= 1.0.4 and < 1.1.0

terraform init
----------------

Provider initialization is one of the actions of terraform init. Running this command will download and initialize any providers that are not already initialized.

Note that terraform init cannot automatically download providers that are not distributed by HashiCorp.

terraform validate
--------------------

Check only configuration state
Will not validate remote state
U should run terraform init before u run validate.

-check-variables=true - If set to true (default), the command will check whether all required variables have been specified.

In terraform if a variable dont have a default value, then it is a required variable. 

This command does not check formatting (e.g. tabs vs spaces, newlines, comments etc.).

The following can be reported:

invalid HCL syntax (e.g. missing trailing quote or equal sign)
invalid HCL references (e.g. variable name or attribute which doesn't exist)
same provider declared multiple times
same module declared multiple times
same resource declared multiple times
invalid module name
interpolation used in places where it's unsupported (e.g. variable, depends_on, module.source, provider)
missing value for a variable (none of -var foo=... flag, -var-file=foo.vars flag, TF_VAR_foo environment variable, terraform.tfvars, or default value in the configuration)

In terraform version 0.12 the terraform validate command does not support the check-variables flag.terraform validate checks if the module implementation itself is valid, not whether a particular plan for it is valid. Variables are part of a plan rather than part of the module itself, so terraform validate does not do any checks of their values. (it does, however, detect if they are being used consistently in the module, such as producing an error if a string variable is used where a list is expected.)


Sensitive data
---------------

Defining a variable as sensitive: Terraform will then redact these values in the output of Terraform commands or log messages.
But it will be saved in state file. So use encrypted backends.

To pass sensitive value use either a secret.tfvars file(do not check in this file) or use env variables.

The AWS provider considers the password argument for any database instance as sensitive, whether or not you declare the variable as sensitive, and will redact it as a sensitive value. You should still declare this variable as sensitive to make sure it's redacted if you reference it in other locations than the specific password argument.


Referencing secret value as outputs:
When you use sensitive variables in your Terraform configuration, you can use them as you would any other variable. Terraform will redact these values in command output and log files, and raise an error when it detects that they will be exposed in other ways.
If u refer a sensitive value in output, terraform will raise an error!!

Terraform Cloud and Terraform Enterprise manage and share sensitive values, and encrypt all variable values before storing them. **HashiCorp Vault** secures, stores, and tightly controls access to tokens, passwords, and other sensitive values.

Child and Parent Module
--------------------------
All modules are self-contained, and a child module does not inherit variables from the parent. You have to explicitly define the variables in the module, and then set them in the parent module when you create the module.


For_each and count
----------------

A given resource or module block cannot use both count and for_each.

The for_each meta-argument accepts a map or a set of strings, and creates an instance for each item in that map or set. 

```
resource "azurerm_resource_group" "rg" {
  for_each = {
    a_group = "eastus"
    another_group = "westus2"
  }
  name     = each.key
  location = each.value
}

resource "aws_iam_user" "the-accounts" {
  for_each = toset( ["Todd", "James", "Alice", "Dottie"] )
  name     = each.key
}


```

The keys of the map (or all the values in the case of a set of strings) must be known values. for_each keys cannot be the result (or rely on the result of) of impure functions, including uuid, bcrypt, or timestamp, as their evaluation is deferred during the main evaluation step.

Sensitive values, such as sensitive input variables, sensitive outputs, or sensitive resource attributes, cannot be used as arguments to for_each. Terraform will through an error

Referencing: <TYPE>.<NAME>[<KEY>]
azurerm_resource_group.rg["a_group"],
azurerm_resource_group.rg["another_group"]

This is different from resources and modules without count or for_each, which can be referenced without an index or key.

Splat Expression:
**var.list[*].id**  is same as **[for o in var.list : o.id]**

The splat expression patterns shown above apply only to lists, sets, and tuples. Cannot be used with for_each map objects.

Count:
Instances are identified by an index number, starting with 0.

Referencing: <TYPE>.<NAME>[<INDEX>]

when to use:
If your instances are almost identical, count is appropriate. If some of their arguments need distinct values that can't be directly derived from an integer, it's safer to use for_each.

for Expression

[for s in var.list : upper(s)]

[for k, v in var.map : length(k) + length(v)]

The type of brackets around the for expression decide what type of result it produces.

The above example uses [ and ], which produces a tuple. If you use { and } instead, the result is an object and you must provide two result expressions that are separated by the => symbol:

{for s in var.list : s => upper(s)}
This expression produces an object whose attributes are the original elements from var.list and their corresponding values are the uppercase versions. 

{
  foo = "FOO"
  bar = "BAR"
  baz = "BAZ"
}

For maps and objects, Terraform sorts the elements by key or attribute name, using lexical sorting.

You can't dynamically generate nested blocks using for expressions, but you can generate nested blocks for a resource dynamically using dynamic blocks.







