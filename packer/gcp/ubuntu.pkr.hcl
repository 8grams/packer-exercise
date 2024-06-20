// To run
// init -> packer init .
// validate syntax -> packer validate .
// build -> packer build ubuntu.pkr.hcl

packer {
  required_plugins {
    // https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute
    googlecompute = {
      version = ">= 1.1.4"
      source = "github.com/hashicorp/googlecompute"

      // use provided credentials file 
      // credentials_file = "./google.json"
    }

    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

// https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute/latest/components/builder/googlecompute
source "googlecompute" "ubuntu" {
  project_id = var.project_id
  instance_name = "onxp-ubuntu-jammy"
  // add suffix (timestamp) and image_family to determine which image is latest
  image_name = "onxp-ubuntu-jammy-${local.timestamp}"

  // how to crete custom image family: https://cloud.google.com/compute/docs/images/create-custom#setting_families
  source_image = "ubuntu-2204-jammy-v20240319"
  ssh_username = "glendmaatita.me@gmail.com"
  zone = "us-central1-a"
  disk_size = 20
  machine_type = "e2-micro"
  disk_type = "pd-standard"
  communicator = "ssh"

  // dest image
  image_project_id = var.project_id
  image_storage_locations = ["us-central1"]
  image_family = "onxp-ubuntu-jammy"
}

build {
  name    = "onxp-packer-ubuntu"
  sources = [
    "source.googlecompute.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "BOOTCAMP=OnXP",
    ]

    inline = [
      "echo 'Using shell provisioner with inline command'",
      "sudo mkdir -p /opt/data",
      "sudo chmod 777 -R /opt/data",
      "echo \"Hello, $BOOTCAMP!\" > /opt/data/hello.txt",
      "sudo apt update -y && sudo apt install -y nginx certbot python3-certbot-nginx",
    ]
  }

  // using ansible provisioner
  // https://developer.hashicorp.com/packer/integrations/hashicorp/ansible
  provisioner "ansible" {
    playbook_file = "./../../ansible/docker/playbook.yaml"
    extra_arguments = [ "--scp-extra-args", "'-O'" ]
  }
}

variable "project_id" {
  type    = string
  default = "mashanz-software-engineering"
}

// set as image suffix
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}