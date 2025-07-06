terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3" # En güncel ve stabil versiyonu kullanalım
    }
  }
}

provider "libvirt" {
}

resource "libvirt_volume" "debian12_cloud_image_base" {
  name   = "debian12-cloud-base-image.qcow2"
  pool   = "default"
  source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  format = "qcow2"
  # Disk 'size' tekrar mount edilirken verilirse direkt boyutu ayarlanabilir.
}

# --- Önceki volümü al ve boyutunu 20GB'a genişlet ---
# Size Parametresi Burada Kullanılır.
resource "libvirt_volume" "debian12_base_disk_expanded" {
  name           = "debian12-base-disk-expanded.qcow2" # Genişletilmiş disk için ayrı bir isim
  pool           = "default"
  # 'source' yerine 'base_volume_id' kullanarak mevcut bir volümü referans alıyoruz.
  base_volume_id = libvirt_volume.debian12_cloud_image_base.id 
  format         = "qcow2"
  size           = 20 * 1024 * 1024 * 1024 # 20 GB byte olarak.
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
    # Sanal makineye genişletilmiş diski bağlıyoruz
    volume_id = libvirt_volume.debian12_base_disk_expanded.id
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