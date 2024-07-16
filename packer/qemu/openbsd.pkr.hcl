// packer build ubuntu.pkr.hcl
packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "openbsd7" {
  iso_url      = "https://cdn.openbsd.org/pub/OpenBSD/7.4/amd64/install74.iso"
  iso_checksum = "sha256:a1001736ed9fe2307965b5fcdb426ae11f9b80d26eb21e404a705144a0a224a0"

  ssh_username = "root"
  ssh_password = "onxpsecret"

  disk_size    = 10240
  memory       = 1024
  format       = "qcow2"
  accelerator  = "kvm"

  net_device   = "e1000"
  boot_command = [
    "<wait5><wait5><wait5><esc><wait>",
    "i<wait>",
    "set tty com0<enter>",
    "stty com0 9600<enter>",
    "boot com0<enter>"
  ]
}

build {
  sources = [
    "source.qemu.openbsd7"
  ]
}