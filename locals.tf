locals {
  environment = "production"

  location = "Canada Central"

  REGIONS = {
    "Canada Central" : "cancen",
    "Canada East" : "caneas",
    "East US" : "eastus"
  }
  location_key = local.REGIONS[local.location]

  tags = {
    environment = var.environment
    product     = var.product_key
    managed_by  = "terraform"
  }

  environment_key = substr(var.environment, 0, 4)

  # Availability sets can be configured with up to 3 fault domains.
  # https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview#how-do-availability-sets-work
  # However, max fault domains are region-dependent.
  platform_fault_domain_count = "3"
}
