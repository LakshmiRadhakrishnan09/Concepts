https://github.com/adv4000/terraform_certified/tree/master/Lab-01
https://www.examtopics.com/exams/hashicorp/terraform-associate/view/
https://codingnconcepts.com/post/terraform-associate-exam-questions/


terraform show : full state. All resource configuration
terraform show -json ; Json representation of state.
terraform state list : lists all resoures in terraform state
terraform state show <resource_name> : configuration of a resource

Question:
You have deployed a new webapp with a public IP address on a cloud provider. However, you did not create any outputs for your code. What is the best method to quickly find the IP address of the resource you deployed?

Answer: Run 'terraform state list' to find the name of the resource, then 'terraform state show address'to find the attributes including public IP address


Question: 
All standard backend types support remote state storage, state locking, and encryption at rest?

Answer:
False
No, All the standard backend doesn’t support all three. local backend type doesn’t support remote state storage, artifactory and etcd backend types doesn’t support state locking.

Github is not a valid backend type supported by Terraform


Question
Your co-worker has decided to migrate Terraform state to a remote backend. They configure Terraform with the backend configuration, including the type, location, and credentials. However, you want to better secure this configuration. Rather than storing them in plaintext, where should you store the credentials? (select two)

Answer:
credentials file
Envt variables

Question
You can migrate the Terraform backend but only if there are no resources currently being managed.

Answer: False
Terraform will automatically detect any changes in your configuration/backend and request a reinitialization. As part of the reinitialization process, Terraform will ask if you’d like to migrate your existing state to the new configuration. This allows you to easily switch from one backend to another.

Question
You have decided to migrate the Terraform state to a remote s3 backend. You have added the backend block in the Terraform configuration. Which command you should run to migrate the state?

Answer
terraform init

When you change a backend’s configuration, you must run terraform init again to validate and configure the backend before you can perform any plans, applies, or state operations.

Question
Provisioners should only be used as a last resort.

Answer
True

**Provisioners should only be used as a last resort.** They add a considerable amount of complexity and uncertainty to Terraform usage. For most common situations there are better alternatives available.

Q
Which type of connections supported by file provisioner? Select all valid options.

A
ssh, winrm

Q
What are the two accepted values for provisioners that have the “on_failure” key specified? (Choose 2 answers)

A
continue, fail

By default, provisioners that fail will also cause the Terraform apply itself to fail. The on_failure setting can be used to change this. The allowed values are: continue and fail

Q
A provider configuration block is required in every Terraform configuration.

A
False


Unlike many other objects in the Terraform language, a provider block may be omitted if its contents would otherwise be empty. Terraform assumes an empty default configuration for any provider that is not explicitly configured.


Q
variable "vpc_cidrs" {
  type = map
  default = {
    us-east-1 = "10.0.0.0/16"
    us-east-2 = "10.1.0.0/16"
    us-west-1 = "10.2.0.0/16"
    us-west-2 = "10.3.0.0/16"
  }
}
How would you define the cidr_block for us-east-1 in the aws_vpc resource using a variable?

A
var.vpc_cidrs["us-east-1"]
Variable of type map values are referenced using key e.g. us-east-1

Q
variable "fruits" {
    type = list(string)
    default = [
        "mango",
        "apple",
        "banana",
        "orange",
        "grapes"
    ]
}

How would you reference banana in your configuration?

A
var.fruits[2]
Variable of type list values are referenced using index that start with 0

Q

resource "aws_instance" "example" {
  ami           = "ami-abc123"
  instance_type = "t2.micro"

  ebs_block_device {
    device_name = "sda2"
    volume_size = 16
  }
  ebs_block_device {
    device_name = "sda3"
    volume_size = 20
  }
}

How can you obtain a list of all of the device_name values from ebs_block_device nested blocks, that are created by this resource block?

A
aws_instance.example.ebs_block_device[*].device_name

Q

resource "aws_instance" "demo" {
  # ...
  for_each = {
    "terraform": "infrastructure",
    "vault":     "security",
    "consul":    "connectivity",
    "nomad":     "scheduler",
  }
}
What resource address should be used for the instance related to vault?

A

aws_instance.demo["vault"]

Q
When are output variables ran and sent to stdout?

A
Only on terraform apply



Q

When specifying a module, what is the best practice for the implementation of the meta-argument version?


A
The best practice is to explicitly set the version argument as a version constraint string from the Terraform registry.

In a parent module, outputs of child modules are available in expressions as: module.<MODULE NAME>.<OUTPUT NAME>

Q
Your security team scanned some Terraform workspaces and found secrets stored in a plaintext in state files. How can you protect sensitive data stored in Terraform state files?

A
Store the state in an encrypted backend

.terraform.lock.hcl - commit this
.tfstate - add to .gitignore
.tfvars - add to .gitignore
.terraform directory - add to .gitignore

Q
What Terraform feature is most applicable for managing small differences between different environments, for example development and production?


A
workspaces

For local state, Terraform stores the workspace states in a directory called terraform.tfstate.d. This directory should be treated similarly to local-only terraform.tfstate.

Q
terraform {
  required_version = ">= 1.3.8"
}

What does this mean?

The user wants to specify the minimum version of Terraform that is required to run the configuration

Q

terraform { required_providers { aws = { source = “hashicorp/aws” version =”3.74.1″ } } }

A
orce users to use a particular version of required providers in your terraform code

Q
what are the types in terraform

A
Primitive Types

string, number, bool

Complex Types

collection type : of same time

list(), map(), set()

eg for map { "foo": "bar", "bar": "baz" } OR { foo = "bar", bar = "baz" }

Structural type: of different type. Need a schema

object(), tuple()

schema of object() : { <KEY> = <TYPE>, <KEY> = <TYPE>, ... }
eg: object({ name=string, age=number })
Values that match the object type must contain all of the specified keys, and the value for each key must match its specified type. (Values with additional keys can still match an object type, but the extra attributes are discarded during type conversion.)

schema of tuple is: [<TYPE>, <TYPE>, ...]
eg: tuple([string, number, bool])
Values that match the tuple type must have exactly the same number of elements (no more and no fewer), and the value in each position must match the specified type for that position.

Q
Which of the following is not a valid string function in Terraform?

A
slice()

String functions - join(), split(), chomp(), endswith(), format(), substr()

chomp() : removes newline characters at the end of a string.

Q
What are some built-in functions that terraform provides?

A
max(), regex(), alltrue()

Q
One remote backend configuration always maps to a single remote workspace.

A
False

Q
Terraform variables and outputs that set the "description" argument will store that description in the state file.

A
False. Description will not be stored in state file.

Q
If a module uses a local values, you can expose that value with a terraform output.

A
True

locals {
 some_local_value = ""
}

output "my_local_vale"{
  value = local.some_local_value
}

Q
A Terraform provisioner must be nested inside a resource configuration block.

A
True

Q

You have declared a variable called var.list which is a list of objects that all have an attribute id.
Which options will produce a list of the IDs? (Choose two.)

A

var.list[*].id 
[ for o in var.list : o.id ]

Terrfaorm variable arguments - default, type are all optional. Nothing is mandatory

Q
Which option can not be used to keep secrets out of Terraform configuration files?

Providers, secure string, env variable, -var flag

A

secure string
Vault is a provider.

Q
In Terraform 0.13 and above, outside of the required_providers block, Terraform configurations always refer to providers by their local names.

A
TRUE

Each provider has two identifiers. Local name and unique source address. Local names must be unique per module.
Outside of the required_providers block, Terraform configurations always refer to providers by their local names.  

aws , google are all providers local name.

Q
Terraform providers are always installed from the Internet.

A
False

For air gapped systems, we can bundle provider along with the Terraform binaries. These Bundle can be installed without internet on air gapped system.  NOTE: For downloading the bundle we need internet access, this can be done on a system which as internet access and later transfer to the air gapped system

Q
When does terraform apply reflect changes in the cloud environment?

A
Not sure - However long it takes the resource provider to fulfill the request

When u apply
1. Terraform will lock the state file
2. Create a plan
3. Execute steps
4. Update state
5. Unlock state file
6. Report

Your infrastructure may be in an invalid state after a Terraform apply step errors out. Terraform does not support automatically rolling back a partially-completed apply. 

Q
A Terraform provider is not responsible for:

A
Not sure - Provisioning infrastructure in multiple clouds 

Providers are responsible in Terraform for managing the lifecycle of a resource: create, read, update, delete.

Q
Which flag would you add to terraform plan to save the execution plan to a file?
A
**-out**

Q
Which of these options is the most secure place to store secrets foe connecting to a Terraform remote backend?

A
Not sure - Env Variable or Vault

Q
When you initialize Terraform, where does it cache modules from the public Terraform Module Registry?
A
.terraform directory

Q
Which of the following is allowed as a Terraform variable name?

A
name

Not allowed : source, version, count, depends_on, providers, for_each, lifecycle, locals

Q
Module variable assignments are inherited from the parent module and do not need to be explicitly set.
A
Not sure - 

Q

If writing Terraform code that adheres to the Terraform style conventions, how would you **properly indent each nesting level compared to the one above it**?

A
two spaces

Q
HashiCorp Configuration Language (HCL) supports user-defined functions.

A
FALSE

HCL does not support user defined functions

Q
Terraform and Terraform providers must use the same major version number in a single configuration.

A
FALSE
terraform version and providers version can be different.

Q
Which option cannot be used to keep secrets out of Terraform configuration files?
A. Environment Variables
B. Mark the variable as sensitive 
C. A Terraform provider
D. A -var flag

A
Mark the variable as sensitive. It wont be showed in console, but still it is part of configuration.
Terraform will redact the values of sensitive variables in console and log output, to reduce the risk of accidentally disclosing these values. The value will be in state file.

Q
How would you reference the Volume IDs associated with the ebs_block_device blocks in this configuration?
``
resource "aws_instance" "example" {
ami = "ami-abc123"
instance_type - "t2.micro"
ebs block device f
device name = "sda2"
volume size = 16
ebs block device {
device_name = "sda3"
volume
_size = 20
}
｝
``
A. aws_instance.example.ebs_block_device.[*].volume_id Most Voted
B. aws_instance.example.ebs_block_device.volume_id
C. aws_instance.example.ebs_block_device[sda2,sda3].volume_id
D. aws_instance.example.ebs_block_device.*.volume_id 

A
aws_instance.example.ebs_block_device.*.volume_id 

Option A has a extra dot

aws_instance.example.ebs_block_device.*.volume_id and aws_instance.example.ebs_block_device[*].volume_id

Q
All modules published on the official Terraform Module Registry have been verified by HashiCorp.

A
FALSE
Any one can publish

Verified modules are reviewed by HashiCorp and actively maintained by contributors to stay up-to-date and compatible with both Terraform and their respective providers.

The verified badge appears next to modules that are published by a verified source.


Q
How do you specify a module's version when publishing it to the public Terraform Module Registry?
A
The release tags in the associated repo
Release tag names must be a semantic version, which can optionally be prefixed with a v . For example, v1. 0.4 and 0.9.


Q

All Terraform Cloud tiers support team management and governance.

A

FALSE

Free Tie doent support team management.

Q
Which of the following is not an advantage of using infrastructure as code operations?

A
Public cloud console configuration workflows

Q
You can reference a resource created with for_each using a Splat (*) expression.

A
FALSE

