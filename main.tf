resource "null_resource" "dependency" {
  triggers = {
    dependency = var.dependency
  }
}

resource "random_id" "encrypt" {
  byte_length = 16
}

locals {
  nomad_version = var.nomad_version == null ? "" : var.nomad_version
  config_file = templatefile("${path.module}/templates/nomad.hcl.tpl", {
    agent_type       = var.agent_type
    datacenter       = var.datacenter
    data_dir         = var.data_dir
    bootstrap_expect = var.bootstrap_expect
    retry_join       = jsonencode(var.retry_join)
    log_level        = var.log_level
    }
  )
  upload_binary_trigger   = var.nomad_binary == null ? null : null_resource.upload_binary[0].id
  download_binary_trigger = var.nomad_binary == null ? null_resource.download_binary[0].id : null
}

resource "null_resource" "prereqs" {
  depends_on = [null_resource.dependency]

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.username
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/install-prereqs.sh"
  }
}

resource "null_resource" "download_binary" {
  count      = var.nomad_binary == null ? 1 : 0
  depends_on = [null_resource.dependency, null_resource.prereqs]
  triggers = {
    version = var.nomad_version
  }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.username
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    source      = "${path.module}/scripts/download-nomad.sh"
    destination = "download-nomad.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x download-nomad.sh",
      "NOMAD_VERSION=${local.nomad_version} ./download-nomad.sh"
    ]
  }
}

resource "null_resource" "upload_binary" {
  count      = var.nomad_binary == null ? 0 : 1
  depends_on = [null_resource.dependency, null_resource.prereqs]
  triggers = {
    binary = var.nomad_binary
  }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.username
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    source      = var.nomad_binary
    destination = "nomad"
  }
}

resource "null_resource" "install_binary" {
  depends_on = [null_resource.dependency, null_resource.download_binary, null_resource.upload_binary]
  triggers = {
    download_binary = local.download_binary_trigger
    upload_binary   = local.upload_binary_trigger
  }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.username
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/install-nomad-binary.sh"
  }
}

resource "null_resource" "install_service" {
  depends_on = [null_resource.dependency, null_resource.install_binary]

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.username
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install-nomad-service.sh"
    destination = "install-nomad-service.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x install-nomad-service.sh",
      "NOMAD_DATA_DIR=${var.data_dir} ./install-nomad-service.sh"
    ]
  }
}

resource "null_resource" "configure" {
  depends_on = [
    null_resource.dependency,
    null_resource.prereqs,
    null_resource.download_binary,
    null_resource.upload_binary,
    null_resource.install_service
  ]
  triggers = {
    template = local.config_file
    install  = null_resource.install_binary.id
  }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.username
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    content     = local.config_file
    destination = "nomad.hcl"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/configure-nomad.sh"
  }
}

resource "null_resource" "complete" {
  depends_on = [
    null_resource.prereqs,
    null_resource.download_binary,
    null_resource.upload_binary,
    null_resource.install_binary,
    null_resource.install_service,
    null_resource.configure
  ]

  triggers = {
    prereqs         = null_resource.prereqs.id
    download_binary = local.download_binary_trigger
    upload_binary   = local.upload_binary_trigger
    install_binary  = null_resource.install_binary.id
    install_service = null_resource.install_service.id
    configure       = null_resource.configure.id

    # always = timestamp()
  }
}
