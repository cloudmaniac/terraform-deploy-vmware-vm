# Provider
provider_vsphere_host = "vcsa01-z67.sddc.lab"
provider_vsphere_user = "administrator@vsphere.local"
provider_vsphere_password = "VMware1!"

# Infrastructure
deploy_vsphere_datacenter = "MGMT-Z67"
deploy_vsphere_cluster = "CL01-Z67"
deploy_vsphere_datastore = "vsanDatastore"
deploy_vsphere_folder = "/kubernetes"
deploy_vsphere_network = "PG-10.67.31.0"

# Guest
guest_template = "packer-ubuntu-18.04"
guest_vcpu = "2"
guest_memory = "2048"
guest_ipv4_netmask = "24"
guest_ipv4_gateway = "10.67.31.254"
guest_dns_servers = "10.67.10.5"
guest_dns_suffix = "pod03.lab.local"
guest_domain = "sddc.lab"