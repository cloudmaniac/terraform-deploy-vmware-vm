# Provider
provider_vsphere_host     = "vcsa01-z67.sddc.lab"
provider_vsphere_user     = "administrator@vsphere.local"
provider_vsphere_password = "VMware1!"

# Infrastructure
deploy_vsphere_datacenter = "MGMT-Z67"
deploy_vsphere_cluster    = "CL01-Z67"
deploy_vsphere_datastore  = "vsanDatastore"
deploy_vsphere_folder     = "/kubernetes"
deploy_vsphere_network    = "PG-10.67.11.0"

# Guest
guest_name_prefix     = "k8s-prod"
guest_template        = "packer-ubuntu-18.04"
guest_vcpu            = "1"
guest_memory          = "1024"
guest_ipv4_netmask    = "24"
guest_ipv4_gateway    = "10.67.11.254"
guest_dns_servers     = "10.67.10.5"
guest_dns_suffix      = "sddc.lab"
guest_domain          = "sddc.lab"
guest_ssh_user        = "packer"
guest_ssh_password    = "VMware1!"
guest_ssh_key_private = "~/.ssh/id_ed25519"
guest_ssh_key_public  = "~/.ssh/id_ed25519.pub"
guest_firmware        = "efi"

# Master(s)
master_ips = {
  "0" = "10.67.11.11"
  "1" = "10.67.11.12"
  "2" = "10.67.11.13"
}

# Worker(s)
worker_ips = {
  "0" = "10.67.11.21"
  "1" = "10.67.11.22"
  "2" = "10.67.11.23"
  "3" = "10.67.11.24"
}
