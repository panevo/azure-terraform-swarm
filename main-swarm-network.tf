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


resource "azurerm_availability_set" "vm_availabilityset_workers" {
  name                         = "${local.product_key}-${local.environment_key}-availabilityset-worker-${local.location_key}${var.name_postfix}"
  resource_group_name          = azurerm_resource_group.swarm_cluster.name
  location                     = azurerm_resource_group.swarm_cluster.location
  tags                         = local.tags
  platform_update_domain_count = 5
  platform_fault_domain_count  = local.platform_fault_domain_count

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

# Network security rules for managers
resource "azurerm_network_security_group" "manager_sg" {
  name                = "${local.product_key}-${local.environment_key}-nic-sg-managers-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location

  tags = local.tags
}

# Network security rules for workers
resource "azurerm_network_security_group" "worker_sg" {
  name                = "${local.product_key}-${local.environment_key}-nic-sg-workers-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location

  tags = local.tags
}
