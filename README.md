# Deploy one or multiple VMware VM(s) with Terraform

## Overview

I created a [GitHub repository](https://github.com/cloudmaniac/ansible-deploy-vmware-vm) 18 months ago to share how Ansible can be used to deploy multiple vSphere virtual machines from a template.

Ansible was my first choice to clone virtual machines and build/configure vSphere infrastructure as I was already used to it. However, I switched to Terraform in 2019 for various reasons such as immutable infrastructure, state management, the possibility to destroy resources easily, and much more.

This repository provides an example (and a memo for myself) on **how to clone a vSphere template into one or multiple virtual machines using Terraform**.

## Terraform

[HashiCorp Terraform](https://www.terraform.io/) allows infrastructure to be expressed as code in a simple, human-readable language called HCL (HashiCorp Configuration Language). Terraform uses this language to provide an execution plan of changes, which can be reviewed for safety and then applied to make changes.

Almost any infrastructure type can be represented as a **resource** in Terraform. While resources are the primary construct in the Terraform language, the _behaviors_ of resources rely on their associated resource types, and these types are defined by _providers_.

[Providers](https://www.terraform.io/docs/providers/index.html) are responsible for understanding API interactions and exposing resources to the outside world. Extensible providers allow Terraform to manage a broad range of resources, including hardware, iaas, paas, and saas services.

In the example below, the `vsphere_virtual_machine` resource from the [VMware vSphere provider](https://www.terraform.io/docs/providers/vsphere/index.html) is leveraged to clone and configure multiple vSphere virtual machines.

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) 0.12+

## Configuration

The set of files used to describe infrastructure in Terraform is simply known as a Terraform _configuration_.:

    ├── main.tf
    ├── output.tf
    ├── terraform.tfvars
    └── variables.tf


1. The `main.tf` file contains my provider definition as well as the **logic**: while _data sources_ allow data to be fetched or computed for use elsewhere in the configuration (e.g., vSphere cluster, datastore, portgroup, and so on), the _resource_ blocks describe the virtual machines to create. 
2. The `variables.tf` file contains the variables definition within your Terraform configuration (but not the values of those variables which are defined in  `terraform.tfvars`).
3. For all files which match `terraform.tfvars` or `*.auto.tfvars` present in the current directory, Terraform automatically loads them to populate variables. **This file has to be updated to match your infrastructure settings**.
4. (optional) The `output.tf` file provides useful information for troubleshooting purposes.

> **Note:** Although .tfvars files are *usually* not distributed for security reasons, I included mine here for demonstration purposes.

## Resources

Two `vsphere_virtual_machine` resource blocks are defined:

 - `kubernetes_master` clones a Linux vSphere template into a new virtual machine and customize the guest.
 - `kubernetes_workers` clones a Linux vSphere template into multiple new virtual machines and customize the guests; `count.index` was used to loop over resources, but other mechanisms can be used as a replacement (such as `for_each` or `for` loops).

## Execution

### Init

The first command to run for a new configuration is  `terraform init`, which initializes various local settings and data that will be used by subsequent commands. This command will also automatically download and install any provider defined in the configuration.

    \❯ terraform init
    
    Initializing the backend...
    Initializing provider plugins...
    
    The following providers do not have any version constraints in configuration,
    so the latest version was installed.
    
    To prevent automatic upgrades to new major versions that may contain breaking
    changes, it is recommended to add version = "..." constraints to the
    corresponding provider blocks in configuration, with the constraint strings
    suggested below.
    
    * provider.vsphere: version = "~> 1.14"
    
    Terraform has been successfully initialized!
    
    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.
    
    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.

### Plan

The  `terraform plan`  command is used to create an execution plan. Terraform performs a refresh, unless explicitly disabled, and then determines what actions are necessary to achieve the desired state specified in the configuration files.

This command is a convenient way to check whether the execution plan for a set of changes matches your expectations without making any changes to real resources or to the state.

### Apply

The `terraform apply` command is used to **apply the changes required to reach the desired state of the configuration**.

    \❯ terraform apply
    data.vsphere_datacenter.target_dc: Refreshing state...
    data.vsphere_network.target_network: Refreshing state...
    data.vsphere_compute_cluster.target_cluster: Refreshing state...
    data.vsphere_virtual_machine.source_template: Refreshing state...
    data.vsphere_datastore.target_datastore: Refreshing state...
    vsphere_virtual_machine.kubernetes_workers[2]: Refreshing state... [id=422fd79c-755b-a2d4-bb09-c9d6476217f5]
    vsphere_virtual_machine.kubernetes_master: Refreshing state... [id=422faaf3-2f12-b3ee-f0ed-8d602bfa4b11]
    vsphere_virtual_machine.kubernetes_workers[1]: Refreshing state... [id=422ff5fb-7c96-1494-a865-6969a6fdd52f]
    vsphere_virtual_machine.kubernetes_workers[0]: Refreshing state... [id=422f4d66-fc03-14ed-767b-62ade0142d19]
    
    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create
      ~ update in-place
    
    Terraform will perform the following actions:
    
      # vsphere_virtual_machine.kubernetes_master will be updated in-place
      ~ resource "vsphere_virtual_machine" "kubernetes_master" {
          - annotation                              = "Ubuntu 18.04.3 LTS (Bionic Beaver) - 2020-01-10" -> null
    
    [...]
    
    Plan: 1 to add, 3 to change, 0 to destroy.
    
    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.
    
      Enter a value: yes

Once the resources are provisioned, the state will be stored by default in a local file named `terraform.tfstate`; it can also be stored remotely, which works better in a team environment.

### Destroy

If you're using Terraform to spin up multiple environments such as lab, dev, or test environments, then destroying is a useful action.

Resources can be destroyed using the `terraform destroy` command, which is similar to `terraform apply`, but it behaves as if all of the resources have been removed from the configuration.

**Enjoy!** :)
