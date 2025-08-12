data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "this" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled

  enable_rbac_authorization = true
  sku_name                  = var.sku_name
}

resource "azurerm_role_assignment" "example" {
  count = length(var.users_allowed)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = element(var.users_allowed, count.index)
}