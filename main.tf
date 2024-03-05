resource "azurerm_resource_group" "swarm_cluster" {
  name     = "${local.product_key}-${local.environment_key}-${local.location_key}-swarm-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "swarm_cluster_vnet" {
  name                = "${local.product_key}-${local.environment_key}-vnet-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location
  address_space       = ["10.254.0.0/16"] # /16 == 65,536 addresses
  tags                = local.tags

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

resource "azurerm_subnet" "node_subnet" {
  name                 = "${local.product_key}-${local.environment_key}-subnet-backend-${local.location_key}${var.name_postfix}"
  resource_group_name  = azurerm_resource_group.swarm_cluster.name
  virtual_network_name = azurerm_virtual_network.swarm_cluster_vnet.name
  address_prefixes     = ["10.254.2.0/24"] # /24 == 251 + 5 Azure reserved addresses

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}


# ------------------------------------------------------------------
# Virtual Machines - Manager nodes
# ------------------------------------------------------------------
resource "azurerm_availability_set" "vm_availabilityset_manager" {
  name                         = "${local.product_key}-${local.environment_key}-availabilityset-${local.location_key}${var.name_postfix}"
  resource_group_name          = azurerm_resource_group.swarm_cluster.name
  location                     = azurerm_resource_group.swarm_cluster.location
  tags                         = local.tags
  platform_update_domain_count = 5
  platform_fault_domain_count  = local.platform_fault_domain_count

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

resource "azurerm_public_ip" "vm_publicip" {
  name                = "${local.product_key}-${local.environment_key}-publicip-vm-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location
  allocation_method   = "Dynamic"
  domain_name_label   = "${local.product_key}-${local.environment_key}-manager0-${local.location_key}${var.name_postfix}"
  tags                = local.tags
}

resource "azurerm_network_interface" "manager_nic" {
  name                          = "${local.product_key}-${local.environment_key}-nic-managers-${local.location_key}${var.name_postfix}"
  resource_group_name           = azurerm_resource_group.swarm_cluster.name
  location                      = azurerm_resource_group.swarm_cluster.location
  enable_accelerated_networking = true

  tags = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.node_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_publicip.id
    primary                       = true
  }
}


resource "azurerm_network_security_group" "manager_sg" {
  name                = "${local.product_key}-${local.environment_key}-nic-sg-managers-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location

  tags = local.tags

  # Just for testing
  security_rule {
    name                       = "http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "manager_nic_sg" {
  network_interface_id      = azurerm_network_interface.manager_nic.id
  network_security_group_id = azurerm_network_security_group.manager_sg.id
}


resource "azurerm_linux_virtual_machine" "manager0" {
  name                       = "${local.product_key}-${local.environment_key}-vm-manager0-${local.location_key}${var.name_postfix}"
  resource_group_name        = azurerm_resource_group.swarm_cluster.name
  location                   = azurerm_resource_group.swarm_cluster.location
  size                       = local.node_manager_size
  admin_username             = "vm_admin"
  network_interface_ids      = [azurerm_network_interface.manager_nic.id]
  availability_set_id        = azurerm_availability_set.vm_availabilityset_manager.id
  encryption_at_host_enabled = true
  priority                   = "Regular"
  provision_vm_agent         = true
  patch_assessment_mode      = "AutomaticByPlatform"
  patch_mode                 = "AutomaticByPlatform"

  tags = local.tags

  admin_ssh_key {
    username   = "vm_admin"
    public_key = file(var.ssh_private_key_local_path)
  }

  os_disk {
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
  #   custom_data = base64encode(<<-EOF
  #               #!/bin/bash
  #               echo "Hello, World" > index.html
  #               nohup busybox httpd -f -p 80 &
  #               EOF
  #   )
  custom_data = data.cloudinit_config.manager_config.rendered
}
