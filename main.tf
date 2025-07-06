terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
}

resource "libvirt_volume" "debian12-cloud-generic" {
  name = "debian12-cloud-generic.qcow2"
  pool = "default"
  source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "debian12-base-disk" {
  name = "debian12-base-disk.qcow2"
  pool = "default"
  format = "qcow2"
  size = 20
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name           = "debian-12-base-cloudinit.iso"
  pool           = "default"
  user_data      = file("${path.module}/files/cloud-init.yml")
  network_config = file("${path.module}/files/network-config.yml")
}

resource "libvirt_domain" "debian-12-base" {
  name   = "debian-12-base"
  memory = "8192"
  vcpu   = 6

  network_interface {
    bridge = "virbr0"
  }

  disk {
    volume_id = "${libvirt_volume.debian12-cloud-generic.id}"
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit.id


  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
    listen_address = "0.0.0.0"
    autoport = true
  }
}