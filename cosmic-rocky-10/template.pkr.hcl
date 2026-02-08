packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "rocky-10" {
  accelerator      = "kvm"
  boot_command    = [
    "<wait5><up><wait>e<wait><down>down><wait>",
    "<end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart/rocky10.ks<f10>"
  ]
  disk_cache       = "unsafe"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = "virtio-scsi"
  disk_size        = "8192M"
  format           = "qcow2"
  headless         = "true"
  host_port_max    = 2229
  host_port_min    = 2222
  http_directory   = "httpdir"
  http_port_max    = 10089
  http_port_min    = 10082
  # AARCH
  #iso_checksum     = "SHA256:8256689e8043a084da4ed0f1465d24d71ccbaa32b78db77c2efa82291b4e49b1"
  #iso_url          = "https://mirror.nl.leaseweb.net/rockylinux/10/isos/aarch64/Rocky-10.1-aarch64-minimal.iso"
  # x86_64
  iso_checksum     = "SHA256:5aafc2c86e606428cd7c5802b0d28c220f34c181a57eefff2cc6f65214714499"
  iso_url          = "https://mirror.nl.leaseweb.net/rockylinux/10/isos/x86_64/Rocky-10.1-x86_64-minimal.iso"
  net_device       = "virtio-net"
  output_directory = "packer_output"
  qemu_binary      = "/usr/libexec/qemu-kvm"
  qemuargs         = [["-smp", "4"], ["-m", "2048M"], ["-nographic"], ["-serial", "telnet:localhost:4321,server,nowait"]]
  shutdown_command = "systemctl poweroff"
  ssh_password     = "password"
  ssh_port         = 22
  ssh_username     = "root"
  ssh_wait_timeout = "10m"
  vm_name          = "cosmic-rocky-10.qcow2"
}

build {
  sources = ["source.qemu.rocky-10"]

  provisioner "shell" {
    inline = ["yum install -y cloud-init cloud-utils-growpart"]
  }

  provisioner "shell" {
    inline = ["mkdir -p /var/lib/cloud/scripts/per-boot/"]
  }

  provisioner "file" {
    destination = "/var/lib/cloud/scripts/per-boot/10-cloud-set-guest-password"
    source      = "files/10-cloud-set-guest-password"
  }

  provisioner "shell" {
    inline = ["chmod +x /var/lib/cloud/scripts/per-boot/10-cloud-set-guest-password"]
  }

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "files/cloud.cfg"
  }

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg.d/99-cloudstack.cfg"
    source      = "files/99-cloudstack.cfg"
  }

  provisioner "file" {
    destination = "/etc/my.cnf.d/cosmic.cnf"
    source      = "files/cosmic.cnf"
  }

  provisioner "shell" {
    inline = ["fstrim -v /"]
  }

}
