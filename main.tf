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

resource "libvirt_volume" "debian12-base-qcow2" {
  name = "debian12-base.qcow2"
  pool = "default"
  source = "https://cloud.debian.org/images/cloud/bookworm/20250530-2128/debian-12-genericcloud-amd64-20250530-2128.qcow2"
  format = "qcow2"
}

resource "libvirt_domain" "debian-12-base" {
  name   = "debian-12-base"
  memory = "2048"
  vcpu   = 2

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.debian12-base-qcow2.id}"
  }

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