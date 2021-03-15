##### Provider
# - Arguments to configure the VMware vSphere Provider

variable "provider_vsphere_host" {
  description = "vCenter server FQDN or IP - Example: vcsa01-z67.sddc.lab"
}

variable "provider_vsphere_user" {
  description = "vSphere username to use to connect to the environment - Default: administrator@vsphere.local"
  default     = "administrator@vsphere.local"
}

variable "provider_vsphere_password" {
  description = "vSphere password"
}

##### Infrastructure
# - Defines the vCenter / vSphere environment

variable "deploy_vsphere_datacenter" {
  description = "vSphere datacenter in which the virtual machine will be deployed."
}

variable "deploy_vsphere_cluster" {
  description = "vSphere cluster in which the virtual machine will be deployed."
}

variable "deploy_vsphere_datastore" {
  description = "Datastore in which the virtual machine will be deployed."
}

variable "deploy_vsphere_folder" {
  description = "The path to the folder to put this virtual machine in, relative to the datacenter that the resource pool is in."
}

variable "deploy_vsphere_network" {
  description = "Porgroup to which the virtual machine will be connected."
}

##### Guest
# - Describes virtual machine / guest options

variable "guest_name_prefix" {
  description = "VM / hostname prefix for the kubernetes cluster."
}

variable "guest_template" {
  description = "The source virtual machine or template to clone from."
}

variable "guest_vcpu" {
  description = "The number of virtual processors to assign to this virtual machine. Default: 1."
  default     = "1"
}

variable "guest_memory" {
  description = "The size of the virtual machine's memory, in MB. Default: 1024 (1 GB)."
  default     = "1024"
}

variable "guest_ipv4_netmask" {
  description = "The IPv4 subnet mask, in bits (example: 24 for 255.255.255.0)."
}

variable "guest_ipv4_gateway" {
  description = "The IPv4 default gateway."
}

variable "guest_dns_servers" {
  description = "The list of DNS servers to configure on the virtual machine."
}

variable "guest_dns_suffix" {
  description = "A list of DNS search domains to add to the DNS configuration on the virtual machine."
}

variable "guest_domain" {
  description = "The domain name for this machine."
}

variable "guest_ssh_user" {
  description = "SSH username to connect to the guest VM."
}

variable "guest_ssh_password" {
  description = "SSH password to connect to the guest VM."
}

variable "guest_ssh_key_private" {
  description = "SSH private key (e.g., id_rsa) path."
}

variable "guest_ssh_key_public" {
  description = "SSH public key (e.g., id_rsa.pub) path."
}

##### Master(s)
# - Describes master(s) nodes options

variable "master_ips" {
  type        = map(any)
  description = "List of IPs used for the kubernetes master nodes. 1 IP for a single master, or 3 for a multi-master configuration."
}

##### Worker(s)
# - Describes workers(s) nodes (a.k.a., minions) options

variable "worker_ips" {
  type        = map(any)
  description = "List of IPs used for the kubernetes worker nodes."
}