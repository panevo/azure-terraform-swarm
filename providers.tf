terraform {

  # Pin to a specific version. New minor and patch versions may have bugs and
  # we'd want to test it in pre-production environments.
  required_version = "1.6.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.5.1"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }

    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }

  # !!! Since no subscription is set here, the default subscription defined
  # in the Azure CLI will be used.
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli#logging-into-the-azure-cli
}

provider "azurerm" {
  alias           = "ioTORQ_Staging_Production"
  subscription_id = "a86b3c53-aaa6-48e0-b33a-4a0dc7b0ec24"

  features {
    virtual_machine {
      delete_os_disk_on_deletion = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azuread" {

}

provider "random" {

}
