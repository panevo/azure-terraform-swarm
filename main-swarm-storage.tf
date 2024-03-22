# Storage account for shared file storage in the cluster

resource "random_id" "storage_id" {
  byte_length = 6
}

resource "azurerm_storage_account" "cluster_storage" {
  name                              = "${var.product_key}cluster${lower(random_id.storage_id.hex)}"
  resource_group_name               = azurerm_resource_group.swarm_cluster.name
  location                          = azurerm_resource_group.swarm_cluster.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  infrastructure_encryption_enabled = true
  min_tls_version                   = "TLS1_2"

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
    delete_retention_policy {
      days = 7
    }
    restore_policy {
      days = 6
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  public_network_access_enabled = false

  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.node_subnet.id
    ]
  }

  # meta tags
  lifecycle {
    prevent_destroy = false
  }

  tags = local.tags
}



resource "azurerm_storage_share" "share_config" {
  name                 = "config"
  storage_account_name = azurerm_storage_account.cluster_storage.name
  quota                = 10

  access_tier = "Hot"
}

resource "azurerm_storage_share" "share_data" {
  name                 = "data"
  storage_account_name = azurerm_storage_account.cluster_storage.name
  quota                = 5000

  access_tier = "TransactionOptimized"
}

resource "azurerm_storage_share" "protected" {
  name                 = "protected"
  storage_account_name = azurerm_storage_account.cluster_storage.name
  quota                = 10

  access_tier = "Hot"
}
