output "master_ip" {
  value = proxmox_vm_qemu.master.network_interface[0].ip
}

output "worker_ips" {
  value = [for worker in proxmox_vm_qemu.worker : worker.network_interface[0].ip]
}
