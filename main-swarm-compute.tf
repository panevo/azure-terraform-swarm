

# ------------------------------------------------------------------
# Virtual Machines - Manager 0
# This node is used to initialize the swarm
# ------------------------------------------------------------------


resource "azurerm_public_ip" "publicip_manager0" {
  name                = "${local.product_key}-${local.environment_key}-publicip-manager0-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location
  allocation_method   = "Dynamic"
  domain_name_label   = "${local.product_key}-${local.environment_key}-manager0-${local.location_key}${var.name_postfix}"
  tags                = local.tags
}

resource "azurerm_network_interface" "nic_manager0" {
  name                          = "${local.product_key}-${local.environment_key}-nic-manager0-${local.location_key}${var.name_postfix}"
  resource_group_name           = azurerm_resource_group.swarm_cluster.name
  location                      = azurerm_resource_group.swarm_cluster.location
  enable_accelerated_networking = true

  tags = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.node_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip_manager0.id
    primary                       = true
  }
}

resource "azurerm_network_interface_security_group_association" "nic_manager0_sg" {
  network_interface_id      = azurerm_network_interface.nic_manager0.id
  network_security_group_id = azurerm_network_security_group.manager_sg.id
}


resource "azurerm_linux_virtual_machine" "manager0" {
  name                       = "${local.product_key}-${local.environment_key}-vm-manager0-${local.location_key}${var.name_postfix}"
  computer_name              = "manager0"
  resource_group_name        = azurerm_resource_group.swarm_cluster.name
  location                   = azurerm_resource_group.swarm_cluster.location
  size                       = local.node_manager_size
  admin_username             = local.vm_admin_username
  network_interface_ids      = [azurerm_network_interface.nic_manager0.id]
  availability_set_id        = azurerm_availability_set.vm_availabilityset_manager.id
  encryption_at_host_enabled = true
  priority                   = "Regular"
  provision_vm_agent         = true
  patch_assessment_mode      = "AutomaticByPlatform"
  patch_mode                 = "AutomaticByPlatform"

  # prevent automatic reboot to prevent interruption of data streaming
  reboot_setting = "Never"

  tags = local.tags

  admin_ssh_key {
    username   = local.vm_admin_username
    public_key = file(var.ssh_private_key_local_path)
  }

  os_disk {
    #name                 = "${local.product_key}-${local.environment_key}-osdisk-manager0-${local.location_key}${var.name_postfix}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    # Passing a null value will utilize a Managed Storage Account to store Boot Diagnostics
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#storage_account_uri
    storage_account_uri = null
  }
  custom_data = data.template_cloudinit_config.manager_config.rendered

  depends_on = [azurerm_storage_account.cluster_storage]
}

resource "azurerm_managed_disk" "manager0_data" {
  name                 = "manager0-data"
  location             = azurerm_resource_group.swarm_cluster.location
  resource_group_name  = azurerm_resource_group.swarm_cluster.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "manager0_data_attachment" {
  managed_disk_id    = azurerm_managed_disk.manager0_data.id
  virtual_machine_id = azurerm_linux_virtual_machine.manager0.id
  lun                = "0"
  caching            = "ReadWrite"
}

# ------------------------------------------------------------------
# Managers 1 - n
# ------------------------------------------------------------------

resource "azurerm_public_ip" "publicip_managers" {
  count               = local.node_manager_count - 1
  name                = "${local.product_key}-${local.environment_key}-publicip-manager${count.index + 1}-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location
  allocation_method   = "Dynamic"
  domain_name_label   = "${local.product_key}-${local.environment_key}-manager${count.index + 1}-${local.location_key}${var.name_postfix}"
  tags                = local.tags
}

resource "azurerm_network_interface" "nic_managers" {
  count                         = local.node_manager_count - 1
  name                          = "${local.product_key}-${local.environment_key}-nic-manager${count.index + 1}-${local.location_key}${var.name_postfix}"
  resource_group_name           = azurerm_resource_group.swarm_cluster.name
  location                      = azurerm_resource_group.swarm_cluster.location
  enable_accelerated_networking = true

  tags = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.node_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip_managers[count.index].id
    primary                       = true
  }
}

resource "azurerm_network_interface_security_group_association" "nic_managers_sg" {
  count                     = local.node_manager_count - 1
  network_interface_id      = azurerm_network_interface.nic_managers[count.index].id
  network_security_group_id = azurerm_network_security_group.manager_sg.id
}

resource "azurerm_linux_virtual_machine" "managers" {
  count                      = local.node_manager_count - 1
  name                       = "${local.product_key}-${local.environment_key}-vm-manager${count.index + 1}-${local.location_key}${var.name_postfix}"
  computer_name              = "manager${count.index + 1}"
  resource_group_name        = azurerm_resource_group.swarm_cluster.name
  location                   = azurerm_resource_group.swarm_cluster.location
  size                       = local.node_manager_size
  admin_username             = local.vm_admin_username
  network_interface_ids      = [azurerm_network_interface.nic_managers[count.index].id]
  availability_set_id        = azurerm_availability_set.vm_availabilityset_manager.id
  encryption_at_host_enabled = true
  priority                   = "Regular"
  provision_vm_agent         = true
  patch_assessment_mode      = "AutomaticByPlatform"
  patch_mode                 = "AutomaticByPlatform"

  # prevent automatic reboot to prevent interruption of data streaming
  reboot_setting = "Never"

  tags = local.tags

  admin_ssh_key {
    username   = local.vm_admin_username
    public_key = file(var.ssh_private_key_local_path)
  }

  os_disk {
    #name                 = "${local.product_key}-${local.environment_key}-osdisk-manager1-${local.location_key}${var.name_postfix}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    # Passing a null value will utilize a Managed Storage Account to store Boot Diagnostics
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#storage_account_uri
    storage_account_uri = null
  }
  custom_data = data.template_cloudinit_config.manager_config.rendered

  depends_on = [azurerm_storage_account.cluster_storage, azurerm_linux_virtual_machine.manager0]
}

resource "azurerm_managed_disk" "managers_data" {
  count                = local.node_manager_count - 1
  name                 = "manager${count.index + 1}1-data"
  location             = azurerm_resource_group.swarm_cluster.location
  resource_group_name  = azurerm_resource_group.swarm_cluster.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "manager1_data_attachment" {
  count              = local.node_manager_count - 1
  managed_disk_id    = azurerm_managed_disk.managers_data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.managers[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}

# ------------------------------------------------------------------
# Worker node


resource "azurerm_public_ip" "publicip_workers" {
  count               = local.node_worker_count
  name                = "${local.product_key}-${local.environment_key}-publicip-worker${count.index}-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location
  allocation_method   = "Dynamic"
  domain_name_label   = "${local.product_key}-${local.environment_key}-worker${count.index}-${local.location_key}${var.name_postfix}"
  tags                = local.tags
}
resource "azurerm_network_interface" "nic_workers" {
  count                         = local.node_worker_count
  name                          = "${local.product_key}-${local.environment_key}-nic-worker${count.index}-${local.location_key}${var.name_postfix}"
  resource_group_name           = azurerm_resource_group.swarm_cluster.name
  location                      = azurerm_resource_group.swarm_cluster.location
  enable_accelerated_networking = true

  tags = local.tags
  # TODO: check ip config
  # ip_configuration {
  #   name                          = "internal"
  #   subnet_id                     = azurerm_subnet.node_subnet.id
  #   private_ip_address_allocation = "Dynamic"
  # }

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.node_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip_workers[count.index].id
    primary                       = true
  }
}

resource "azurerm_network_interface_security_group_association" "nic_workers_sg" {
  count                     = local.node_worker_count
  network_interface_id      = azurerm_network_interface.nic_workers[count.index].id
  network_security_group_id = azurerm_network_security_group.worker_sg.id
}

resource "azurerm_linux_virtual_machine" "workers" {
  count                      = local.node_worker_count
  name                       = "${local.product_key}-${local.environment_key}-vm-worker${count.index}-${local.location_key}${var.name_postfix}"
  computer_name              = "worker${count.index}"
  resource_group_name        = azurerm_resource_group.swarm_cluster.name
  location                   = azurerm_resource_group.swarm_cluster.location
  size                       = local.node_worker_size
  admin_username             = local.vm_admin_username
  network_interface_ids      = [azurerm_network_interface.nic_workers[count.index].id]
  availability_set_id        = azurerm_availability_set.vm_availabilityset_workers.id
  encryption_at_host_enabled = true
  priority                   = "Regular"
  provision_vm_agent         = true
  patch_assessment_mode      = "AutomaticByPlatform"
  patch_mode                 = "AutomaticByPlatform"

  # prevent automatic reboot to prevent interruption of data streaming
  reboot_setting = "Never"

  tags = local.tags

  admin_ssh_key {
    username   = local.vm_admin_username
    public_key = file(var.ssh_private_key_local_path)
  }

  os_disk {
    #name                 = "${local.product_key}-${local.environment_key}-osdisk-manager1-${local.location_key}${var.name_postfix}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    # Passing a null value will utilize a Managed Storage Account to store Boot Diagnostics
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#storage_account_uri
    storage_account_uri = null
  }
  custom_data = data.template_cloudinit_config.worker_config.rendered

  depends_on = [azurerm_storage_account.cluster_storage, azurerm_linux_virtual_machine.manager0]
}

resource "azurerm_managed_disk" "workers_data" {
  count                = local.node_worker_count
  name                 = "worker${count.index}-data"
  location             = azurerm_resource_group.swarm_cluster.location
  resource_group_name  = azurerm_resource_group.swarm_cluster.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "workers_data_attachment" {
  count              = local.node_worker_count
  managed_disk_id    = azurerm_managed_disk.workers_data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.workers[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}
