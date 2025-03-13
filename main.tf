provider "proxmox" {
  pm_api_url      = "https://votre_proxmox_server:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = "votre_mot_de_passe"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "master" {
  name              = "master"
  target_node       = "votre_node_proxmox"
  clone            = "votre_template_vm"
  os_type          = "cloud-init"
  cores            = 4
  sockets          = 1
  memory           = 8192
  scsihw           = "virtio-scsi-pci"
  bootdisk         = "scsi0"
  agent            = 1

  disk {
    size            = "100G"
    type            = "scsi"
    storage         = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=192.168.1.10/24,gw=192.168.1.1"

  sshkeys = <<EOF
  ssh-rsa AAAAB3... votre_cle_ssh
  EOF
}

resource "proxmox_vm_qemu" "worker" {
  count             = 3
  name              = "worker-${count.index + 1}"
  target_node       = "votre_node_proxmox"
  clone             = "votre_template_vm"
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

  ipconfig0 = "ip=192.168.1.1${count.index + 1}/24,gw=192.168.1.1"

  sshkeys = <<EOF
  ssh-rsa AAAAB3... votre_cle_ssh
  EOF
}
