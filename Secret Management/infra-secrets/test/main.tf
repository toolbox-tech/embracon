terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

#cria um RG temporário
resource "azurerm_resource_group" "test_rg" {
  name     = "rg-akv-test-${random_id.suffix.hex}"
  location = "Brazil South"

tags = {
    Environment = "Test"
    ManagedBy   = "Terraform"
  }
}
#evita conflitos de nome
resource "random_id" "suffix" {
  byte_length = 2
}

#chama o AKV
 module "key_vault_test" {
  source = "../module"

  resource_group_name       = azurerm_resource_group.test_rg.name
  location                  = azurerm_resource_group.test_rg.location
  key_vault_name            = "akv-test-${random_id.suffix.hex}"
  users_allowed_emails      = ["lucimara.silva@tbxtech.com"]
  sku_name                  = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled  = true
  tags = {
    Environment = "Test"
    Purpose     = "Module Validation"
  }
}

output "test_vault_info" {
  value = {
    vault_name = module.key_vault_test.key_vault_name
    vault_uri  = module.key_vault_test.key_vault_uri
    vault_id   = module.key_vault_test.key_vault_id
  }
}

