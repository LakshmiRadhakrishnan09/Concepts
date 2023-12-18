https://github.com/adv4000/terraform_certified/tree/master/Lab-01
https://www.examtopics.com/exams/hashicorp/terraform-associate/view/



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

Remote State
---------------

Remote state is implemented by a backend or by Terraform Cloud, both of which you can configure in your configuration's root module.

Terraform Backend
----------------------
Each tf configuration has a backend.
Backend defines - where is the state file and where the operations are executed.
Some backend support multiple workspaces.

Remote Backend : Execute operations on terraform cloud

Terraform Workspace
-----------------------
The state file belongs to a workspace.
Some backends support multiple named workspaces.

You can have as S3 backend. You can have multiple workspaces associated to this backend.

You cannot delete default workspace.

For local state, Terraform stores the workspace states in a directory called terraform.tfstate.d.

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


provider "google" {
  project = "acme-app"
  region  = "us-central1"
}


alias and version: two provider arguments defined by terraform and available for all providers.

alias: using same provider with different configuration for different resources. Eg: configure aws provider multi-region.

version: not recommended. use provider requirements instaed.

A provider block without an alias argument is the default configuration for that provider. 

Each Terraform module must declare which providers it requires, so that Terraform can install and use them. Provider requirements are declared in a required_providers block. 

terraform {
  required_providers {
    mycloud = {     # local name
      source  = "mycorp/mycloud"  # global source address
      version = "~> 1.0"
    }
  }
}

provider "mycloud" {

}

Users of a provider can use any local name. 
Whenever possible use providers preferred local name. For example harshicorp/aws use aws as local name. Then you can omit provider in your resource configuration. (If a resource doesn't specify which provider configuration to use, Terraform interprets the first word of the resource type as a local provider name.)

resource "aws_instance" {  # first word "aws" is considered as provider.

}


source -> [<HOSTNAME>/]<NAMESPACE>/<TYPE>
hostname by default is registry.terraform.io

required_providers defines the list or providers necessary for deploying resources. This can be a single one, or multiple including aws, azurerm, google, kubernetes, alicloud and a dozen others. 

If you don't declare a particular provider(as required provider), Terraform will create an implicit required_providers declaration assuming that you mean a provider in the hashicorp/ namespace, which makes it seem as though required_providers is only for third-party providers. For third paty privider , required_provider is mandatory. 
