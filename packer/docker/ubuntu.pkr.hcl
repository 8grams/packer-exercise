// To run
// init -> packer init .
// validate syntax -> packer validate .
// build -> packer build ubuntu.pkr.hcl
// run -> docker run -it <IMAGE ID> -c "/bin/sh

packer {
  required_plugins {
    docker = {
      // optional
      version = ">= 1.0.8"

      // more info: https://developer.hashicorp.com/packer/docs/builders
      source = "github.com/hashicorp/docker"
    }
  }
}

// builder type: docker, more info: https://developer.hashicorp.com/packer/integrations/hashicorp/docker
// builder name: ubuntu
source "docker" "ubuntu" {
  // base image, Packer will run it as container and do the provisioning
  image  = var.docker_image

  // commit = true // commit container to docker image
  // discard = true // delete image after build
  export_path = "/opt/data/ubuntu-jammy.tar" // use it if you want to use post-processor docker-import/docker-push
}

// will execute after container running
build {
  name    = "onxp-packer-ubuntu"
  // from source block above
  sources = [
    "source.docker.ubuntu"
  ]

  // list of provisioners available: https://developer.hashicorp.com/packer/docs/provisioners
  provisioner "shell" {
    // add env variables
    environment_vars = [
      "BOOTCAMP=OnXP",
    ]

    // inline command shell
    inline = [
      "echo 'Using shell provisioner with inline command'",
      "mkdir -p /opt/data && echo \"Hello, $BOOTCAMP!\" > /opt/data/hello.txt",
    ]
  }

  // grouping post processors
  post-processors {
    // get artifact from build and import to local docker registry
    // https://developer.hashicorp.com/packer/integrations/hashicorp/docker/latest/components/post-processor/docker-import
    post-processor "docker-import" {
      repository = "glendmaatita/ubuntu-jammy"
      tag = "stable"
    }

    // push to docker registry, must define docker-import as well
    // For integrate with Vault
    // export VAULT_ADDR='http://vault.example.com:8200'
    // export VAULT_TOKEN='your-vault-token'
    // login_username = vault("secret/data/dockerhub", "username")
    // login_password = vault("secret/data/dockerhub", "password")
    // https://developer.hashicorp.com/packer/integrations/hashicorp/docker/latest/components/post-processor/docker-push
    post-processor "docker-push" {
      login = true // set true if using hub docker
      // login_username = "username"
      // login_password = "password"
    }
  }
}

variable "docker_image" {
  type    = string
  default = "ubuntu:jammy"
}
