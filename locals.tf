locals {
  environment = "production"

  location = "Canada Central"


  REGIONS = {
    "Canada Central" : "cancen",
    "Canada East" : "caneas",
    "East US" : "eastus"
  }
  location_key = local.REGIONS[local.location]

  product_key = "tt"
  tags = {
    environment = local.environment
    product     = "test"
    managed_by  = "terraform"
  }

  environment_key = substr(local.environment, 0, 4)

  vm_admin_username = "vm_admin"

  node_manager_count = 3
  node_manager_size  = "Standard_D2s_v3"
  node_worker_count  = 1
  node_worker_size   = "Standard_D2s_v3"

  # Availability sets can be configured with up to 3 fault domains.
  # https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview#how-do-availability-sets-work
  # However, max fault domains are region-dependent.
  platform_fault_domain_count = "3"
}
