# Resource-1: Create Public IP Address for Azure Load Balancer
resource "azurerm_public_ip" "publicip_swarm_lb" {
  name                = "${local.product_key}-${local.environment_key}-publicip-swarm-lb-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# Create Azure Standard Load Balancer
resource "azurerm_lb" "swarm_lb" {
  name                = "${local.product_key}-${local.environment_key}-web-lb-${local.location_key}${var.name_postfix}"
  resource_group_name = azurerm_resource_group.swarm_cluster.name
  location            = azurerm_resource_group.swarm_cluster.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-publicip-1"
    public_ip_address_id = azurerm_public_ip.publicip_swarm_lb.id
  }

  tags = local.tags
}

# Create LB Backend Pool
resource "azurerm_lb_backend_address_pool" "swarm_lb_backend_address_pool" {
  name            = "backend"
  loadbalancer_id = azurerm_lb.swarm_lb.id
}

# Create LB Probe on port 
resource "azurerm_lb_probe" "lb_probe_ssh" {
  name            = "tcp-probe"
  protocol        = "Tcp"
  port            = 22
  loadbalancer_id = azurerm_lb.swarm_lb.id
}

resource "azurerm_lb_probe" "lb_probe_proxy" {
  name            = "proxy-probe"
  protocol        = "Http"
  port            = 8080
  loadbalancer_id = azurerm_lb.swarm_lb.id
  request_path    = "/ping"
}

# Resource-5: Create LB Rule
resource "azurerm_lb_rule" "lb_rule_http" {
  name                           = "http"
  frontend_ip_configuration_name = azurerm_lb.swarm_lb.frontend_ip_configuration[0].name
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80

  probe_id        = azurerm_lb_probe.lb_probe_proxy.id
  loadbalancer_id = azurerm_lb.swarm_lb.id
}

resource "azurerm_lb_rule" "lb_rule_https" {
  name                           = "https"
  frontend_ip_configuration_name = azurerm_lb.swarm_lb.frontend_ip_configuration[0].name
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443

  probe_id        = azurerm_lb_probe.lb_probe_proxy.id
  loadbalancer_id = azurerm_lb.swarm_lb.id
}


# Associate Network Interface and Standard Load Balancer
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association
resource "azurerm_network_interface_backend_address_pool_association" "swarm_nic_lb_associate_manager0" {
  network_interface_id    = azurerm_network_interface.nic_manager0.id
  ip_configuration_name   = azurerm_network_interface.nic_manager0.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.swarm_lb_backend_address_pool.id
}
resource "azurerm_network_interface_backend_address_pool_association" "swarm_nic_lb_associate_managers" {
  count                   = local.node_manager_count - 1
  network_interface_id    = azurerm_network_interface.nic_managers[count.index].id
  ip_configuration_name   = azurerm_network_interface.nic_managers[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.swarm_lb_backend_address_pool.id
}
resource "azurerm_network_interface_backend_address_pool_association" "swarm_nic_lb_associate_workers" {
  count                   = local.node_worker_count
  network_interface_id    = azurerm_network_interface.nic_workers[count.index].id
  ip_configuration_name   = azurerm_network_interface.nic_workers[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.swarm_lb_backend_address_pool.id
}
