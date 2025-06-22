# environments/dev/main.tf
module "key_vault" {
  source = "../../modules/keyvault"

  key_vault_name          = "kv-${var.environment}-${var.application_name}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  purge_protection_enabled = false
  secrets                 = var.secrets

  additional_access_policies = [
    {
      object_id = data.azurerm_client_config.current.object_id
      tenant_id = data.azurerm_client_config.current.tenant_id
      secret_permissions = ["Get", "List"]
    }
  ]
}