##### Provider
provider "vsphere" {
  user           = "${var.provider_vsphere_user}"
  password       = "${var.provider_vsphere_password}"
  vsphere_server = "${var.provider_vsphere_host}"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

##### Data sources
data "vsphere_datacenter" "target_dc" {
  name = "${var.deploy_vsphere_datacenter}"
}

data "vsphere_datastore" "target_datastore" {
  name = "${var.deploy_vsphere_datastore}"
  datacenter_id = "${data.vsphere_datacenter.target_dc.id}"
}

data "vsphere_compute_cluster" "target_cluster" {
  name = "${var.deploy_vsphere_cluster}"
  datacenter_id = "${data.vsphere_datacenter.target_dc.id}"
}

data "vsphere_network" "target_network" {
  name = "${var.deploy_vsphere_network}"
  datacenter_id = "${data.vsphere_datacenter.target_dc.id}"
}

data "vsphere_virtual_machine" "source_template" {
  name = "${var.guest_template}"
  datacenter_id = "${data.vsphere_datacenter.target_dc.id}"
}

##### Resources
# Clones a single Linux VM from a template

resource "vsphere_virtual_machine" "kubernetes_master" {
  name = "prod-k8s-master01"
  resource_pool_id = "${data.vsphere_compute_cluster.target_cluster.resource_pool_id}"
  datastore_id = "${data.vsphere_datastore.target_datastore.id}"
  folder = "${var.deploy_vsphere_folder}"

  num_cpus = "${var.guest_vcpu}"
  memory = "${var.guest_memory}"
  guest_id = "${data.vsphere_virtual_machine.source_template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.source_template.scsi_type}"

  network_interface {
    network_id = "${data.vsphere_network.target_network.id}"
    adapter_type = "${data.vsphere_virtual_machine.source_template.network_interface_types[0]}"
  }

  disk {
    label = "disk0"
    size = "${data.vsphere_virtual_machine.source_template.disks.0.size}"
    eagerly_scrub = "${data.vsphere_virtual_machine.source_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.source_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.source_template.id}"

    customize {
      linux_options {
        host_name = "prod-k8s-master01"
        domain = "${var.guest_domain}"
      }

      network_interface {
        ipv4_address = "10.67.31.11"
        ipv4_netmask = "${var.guest_ipv4_netmask}"
      }

      ipv4_gateway = "${var.guest_ipv4_gateway}"
      dns_server_list = ["${var.guest_dns_servers}"]
      dns_suffix_list = ["${var.guest_dns_suffix}"]
    }
  }
}

# Clones multiple Linux VMs from a template

resource "vsphere_virtual_machine" "kubernetes_workers" {
  count = 3
  name = "prod-k8s-worker0${count.index + 1}"
  resource_pool_id = "${data.vsphere_compute_cluster.target_cluster.resource_pool_id}"
  datastore_id = "${data.vsphere_datastore.target_datastore.id}"
  folder = "${var.deploy_vsphere_folder}"

  num_cpus = "${var.guest_vcpu}"
  memory = "${var.guest_memory}"
  guest_id = "${data.vsphere_virtual_machine.source_template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.source_template.scsi_type}"

  network_interface {
    network_id = "${data.vsphere_network.target_network.id}"
    adapter_type = "${data.vsphere_virtual_machine.source_template.network_interface_types[0]}"
  }

  disk {
    label = "disk0"
    size = "${data.vsphere_virtual_machine.source_template.disks.0.size}"
    eagerly_scrub = "${data.vsphere_virtual_machine.source_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.source_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.source_template.id}"

    customize {
      linux_options {
        host_name = "prod-k8s-worker0${count.index + 1}"
        domain = "${var.guest_domain}"
      }

      network_interface {
        ipv4_address = "10.67.31.${21 + count.index}"
        ipv4_netmask = "${var.guest_ipv4_netmask}"
      }

      ipv4_gateway = "${var.guest_ipv4_gateway}"
      dns_server_list = ["${var.guest_dns_servers}"]
      dns_suffix_list = ["${var.guest_dns_suffix}"]
    }
  }
}