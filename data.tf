data "cloudinit_config" "manager_config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloud-config/manager.yml")
  }
}
