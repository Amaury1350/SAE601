terraform {
  required_version = ">= 0.15"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_debug = true
  pm_tls_insecure = true
  pm_api_url = "https://172.18.61.22:8006/api2/json"
  pm_api_token_id="terraform@pve"
  pm_api_token_secret="0652e5d0-49ef-4fd5-95af-de7ea4d3fdd1"
}

resource "proxmox_vm_qemu" "master" {
  name             = "master"
  target_node      = "datacenter"
  clone            = "template-ubuntu"
  os_type          = "cloud-init"
  cores            = 4
  sockets          = 1
  memory           = 8192
  scsihw           = "virtio-scsi-pci"
  bootdisk         = "scsi0"
  agent            = 1

  disk {
    size           = "100G"
    type           = "scsi"
    storage        = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=172.18.61.23/24,gw=172.18.0.254"
}

resource "proxmox_vm_qemu" "worker" {
  count             = 3
  name              = "worker-${count.index + 1}"
  target_node       = "datacenter"
  clone             = "template-ubuntu"
  os_type           = "cloud-init"
  cores             = 4
  sockets           = 1
  memory            = 8192
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"
  agent             = 1

  disk {
    size            = "100G"
    type            = "scsi"
    storage         = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=172.18.61.24${count.index + 1}/24,gw=172.18.0.254"
}
