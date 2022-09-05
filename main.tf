data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "rp" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "vm_template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "base_vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_resource_pool.rp.id
  firmware         = data.vsphere_virtual_machine.vm_template.firmware
  guest_id         = data.vsphere_virtual_machine.vm_template.guest_id
  folder           = var.folder
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus               = var.num_cpus
  cpu_hot_add_enabled    = data.vsphere_virtual_machine.vm_template.cpu_hot_add_enabled
  cpu_hot_remove_enabled = data.vsphere_virtual_machine.vm_template.cpu_hot_remove_enabled

  memory                 = var.memory
  memory_hot_add_enabled = data.vsphere_virtual_machine.vm_template.memory_hot_add_enabled

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.vm_template.network_interface_types[0]
  }

  disk {
    label            = data.vsphere_virtual_machine.vm_template.disks.0.label
    size             = data.vsphere_virtual_machine.vm_template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.vm_template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.vm_template.disks.0.thin_provisioned
  }

  scsi_type = data.vsphere_virtual_machine.vm_template.scsi_type

  # placeholder while working on for_each
  # dynamic "disk" {
  #   for_each = 
  #   content {
  #     label       = "disk${disk.value.id}"
  #     unit_number = disk.value.id
  #     size        = disk.value.sizeGB
  #   }
  # }

  clone {
    template_uuid = data.vsphere_virtual_machine.vm_template.uuid
    linked_clone  = false

    customize {
      dynamic "linux_options" {
        for_each = length(regexall("windows", data.vsphere_virtual_machine.vm_template.guest_id)) > 0 ? [] : [1]
        content {
          host_name    = var.vm_name
          domain       = var.domain
          time_zone    = var.time_zone["linux"]
          hw_clock_utc = var.utc_clock
        }
      }

      dynamic "windows_options" {
        for_each = length(regexall("windows", data.vsphere_virtual_machine.vm_template.guest_id)) > 0 ? [1] : []
        content {
          computer_name         = var.vm_name
          join_domain           = var.domain
          admin_password        = var.admin_pass
          domain_admin_user     = var.domain_user
          domain_admin_password = var.domain_pass
          organization_name     = var.org_name
          time_zone = var.time_zone["windows"]
        }
      }
      network_interface {
        ipv4_address = var.ip_address
        ipv4_netmask = 22
      }
      ipv4_gateway    = var.gateway
      dns_server_list = var.dns_servers
      dns_suffix_list = [var.domain]
    }
  }
}
