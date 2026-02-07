
source "qemu" "centos-7" {
  accelerator      = "kvm"
  boot_command     = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart/centos7.ks<enter><wait>"]
  disk_cache       = "unsafe"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = "virtio-scsi"
  disk_size        = "8192"
  format           = "qcow2"
  headless         = "true"
  host_port_max    = 2229
  host_port_min    = 2222
  http_directory   = "httpdir"
  http_port_max    = 10089
  http_port_min    = 10082
  iso_checksum     = "07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a"
  iso_url          = "http://ftp.tudelft.nl/centos.org/7/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"
  net_device       = "virtio-net"
  output_directory = "packer_output"
  qemu_binary      = "/usr/libexec/qemu-kvm"
  qemuargs         = [["-smp", "4"], ["-m", "1024M"], ["-nographic"], ["-serial", "telnet:localhost:4321,server,nowait"]]
  shutdown_command = "systemctl poweroff"
  ssh_password     = "password"
  ssh_port         = 22
  ssh_username     = "root"
  ssh_wait_timeout = "15m"
  vm_name          = "cosmic-centos-7.qcow2"
}

build {
  sources = ["source.qemu.centos-7"]

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
