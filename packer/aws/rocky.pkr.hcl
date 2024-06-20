// To run
// init -> packer init .
// validate syntax -> packer validate .
// build -> packer build rocky.pkr.hcl

// set environment variables
// AWS_ACCESS_KEY_ID
// AWS_SECRET_ACCESS_KEY
// AWS_DEFAULT_REGION

packer {
  required_plugins {
    // https://developer.hashicorp.com/packer/integrations/hashicorp/amazon
    amazon = {
      version = "~> 1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

// https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/builder/ebs
source "amazon-ebs" "rocky" {
  ami_name      = "onxp-rocky-9-${local.timestamp}"
  instance_type = "t2.small"
  region        = "us-east-2"
  source_ami    = "ami-051a0f669bb174783"
  ssh_username  = "rocky"
}

build {
  sources = [
    "source.amazon-ebs.rocky"
  ]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo dnf install -y docker-ce docker-ce-cli containerd.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker rocky"
    ]
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}