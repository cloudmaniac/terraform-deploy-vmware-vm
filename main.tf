##### Terraform Initialization
terraform {
  required_version = ">= 0.13"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "1.24.3"
    }
  }
}

##### Provider
provider "vsphere" {
  user           = var.provider_vsphere_user
  password       = var.provider_vsphere_password
  vsphere_server = var.provider_vsphere_host

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

##### Data sources
data "vsphere_datacenter" "target_dc" {
  name = var.deploy_vsphere_datacenter
}

data "vsphere_datastore" "target_datastore" {
  name          = var.deploy_vsphere_datastore
  datacenter_id = data.vsphere_datacenter.target_dc.id
}

data "vsphere_compute_cluster" "target_cluster" {
  name          = var.deploy_vsphere_cluster
  datacenter_id = data.vsphere_datacenter.target_dc.id
}

data "vsphere_network" "target_network" {
  name          = var.deploy_vsphere_network
  datacenter_id = data.vsphere_datacenter.target_dc.id
}

data "vsphere_virtual_machine" "source_template" {
  name          = var.guest_template
  datacenter_id = data.vsphere_datacenter.target_dc.id
}

##### Resources
# Clones a single Linux VM from a template
resource "vsphere_virtual_machine" "kubernetes_master" {
  count            = length(var.master_ips)
  name             = "${var.guest_name_prefix}-master0${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.target_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.target_datastore.id
  folder           = var.deploy_vsphere_folder
  firmware         = var.guest_firmware

  num_cpus = var.guest_vcpu
  memory   = var.guest_memory
  guest_id = data.vsphere_virtual_machine.source_template.guest_id

  scsi_type = data.vsphere_virtual_machine.source_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.target_network.id
    adapter_type = data.vsphere_virtual_machine.source_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.source_template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.source_template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.source_template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.source_template.id

    customize {
      linux_options {
        host_name = "${var.guest_name_prefix}-master0${count.index + 1}"
        domain    = var.guest_domain
      }

      network_interface {
        ipv4_address = lookup(var.master_ips, count.index)
        ipv4_netmask = var.guest_ipv4_netmask
      }

      ipv4_gateway    = var.guest_ipv4_gateway
      dns_server_list = [var.guest_dns_servers]
      dns_suffix_list = [var.guest_dns_suffix]
    }
  }

  boot_delay = 10000

  # Remove existing SSH known hosts as remote identification (host key) changes between deployments.
  provisioner "local-exec" {
    command = "ssh-keygen -R ${self.guest_ip_addresses[0]}"
  }

  # Ansible requires Python to be installed on the remote machines (as well as the local machine).
  provisioner "remote-exec" {
    inline = ["sudo apt-get update && sudo apt-get -qq install python -y"]

    connection {
      type     = "ssh"
      user     = var.guest_ssh_user
      password = var.guest_ssh_password
      host     = self.guest_ip_addresses[0]
    }
  }

  # Disabling SSH authenticity checking StrictHostKeyChecking=no, to avoid beeing asked to add RSA key fingerprint of a host when you access it for the first time.
  provisioner "local-exec" {
    command = "sshpass -p ${var.guest_ssh_password} ssh-copy-id -i ${var.guest_ssh_key_public} -o StrictHostKeyChecking=no ${var.guest_ssh_user}@${self.guest_ip_addresses[0]}"
  }

  # Prepare operating system for kubernetes using Ansible
  #provisioner "local-exec" {
  #  command = "ansible-playbook -i '${self.guest_ip_addresses[0]},' --private-key ${var.guest_ssh_key_private} ../ansible/k8s-preparation.yml"
  #}

  lifecycle {
    ignore_changes = [annotation]
  }
}

# Clones multiple Linux VMs from a template
resource "vsphere_virtual_machine" "kubernetes_workers" {
  count            = length(var.worker_ips)
  name             = "${var.guest_name_prefix}-worker0${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.target_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.target_datastore.id
  folder           = var.deploy_vsphere_folder
  firmware         = var.guest_firmware

  num_cpus = var.guest_vcpu
  memory   = var.guest_memory
  guest_id = data.vsphere_virtual_machine.source_template.guest_id

  scsi_type = data.vsphere_virtual_machine.source_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.target_network.id
    adapter_type = data.vsphere_virtual_machine.source_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.source_template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.source_template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.source_template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.source_template.id

    customize {
      linux_options {
        host_name = "${var.guest_name_prefix}-worker0${count.index + 1}"
        domain    = var.guest_domain
      }

      network_interface {
        ipv4_address = lookup(var.worker_ips, count.index)
        ipv4_netmask = var.guest_ipv4_netmask
      }

      ipv4_gateway    = var.guest_ipv4_gateway
      dns_server_list = [var.guest_dns_servers]
      dns_suffix_list = [var.guest_dns_suffix]
    }
  }

  boot_delay = 10000

  # Remove existing SSH known hosts as remote identification (host key) changes between deployments.
  provisioner "local-exec" {
    command = "ssh-keygen -R ${self.guest_ip_addresses[0]}"
  }

  # Ansible requires Python to be installed on the remote machines (as well as the local machine).
  provisioner "remote-exec" {
    inline = ["sudo apt-get update && sudo apt-get -qq install python -y"]

    connection {
      type     = "ssh"
      user     = var.guest_ssh_user
      password = var.guest_ssh_password
      host     = self.guest_ip_addresses[0]
    }
  }

  # Disabling SSH authenticity checking StrictHostKeyChecking=no, to avoid beeing asked to add RSA key fingerprint of a host when you access it for the first time.
  provisioner "local-exec" {
    command = "sshpass -p ${var.guest_ssh_password} ssh-copy-id -i ${var.guest_ssh_key_public} -o StrictHostKeyChecking=no ${var.guest_ssh_user}@${self.guest_ip_addresses[0]}"
  }

  # Prepare operating system for kubernetes using Ansible
  #provisioner "local-exec" {
  #  command = "ansible-playbook -i '${self.guest_ip_addresses[0]},' --private-key ${var.guest_ssh_key_private} ../ansible/k8s-preparation.yml"
  #}

  lifecycle {
    ignore_changes = [annotation]
  }
}
