data "template_file" "manager_config_file" {
  template = file("${path.module}/cloud-config/manager.yml")

  vars = {
    storage_account_name = azurerm_storage_account.cluster_storage.name
    storage_account_key  = azurerm_storage_account.cluster_storage.primary_access_key
    username             = local.vm_admin_username
  }
}

data "template_cloudinit_config" "manager_config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.manager_config_file.rendered
  }
}


data "template_file" "worker_config_file" {
  template = file("${path.module}/cloud-config/worker.yml")

  vars = {
    storage_account_name = azurerm_storage_account.cluster_storage.name
    storage_account_key  = azurerm_storage_account.cluster_storage.primary_access_key
    username             = local.vm_admin_username
  }
}

data "template_cloudinit_config" "worker_config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.worker_config_file.rendered
  }
}
