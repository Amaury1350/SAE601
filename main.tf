terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.42.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://172.18.61.22:8006/"
  api_token = var.api_token
  insecure = false
  ssh {
    agent    = true
    username = "root"
  }
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

  sshkeys = <<EOF
  ssh-rsa AAAAB3... votre_cle_ssh
  EOF
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

  sshkeys = <<EOF
  ssh-rsa AAAAB3... votre_cle_ssh
  EOF
}
