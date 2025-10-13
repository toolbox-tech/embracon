data "azurerm_client_config" "current" {}

# Buscar usuários do Azure AD pelos emails
data "azuread_user" "users_by_email" {
  count = length(var.users_allowed_emails)
  user_principal_name = element(var.users_allowed_emails, count.index)
}

# Combinar principal_ids diretos com os obtidos via email
locals {
  # Principal IDs diretos da variável users_allowed
  direct_principal_ids = var.users_allowed
  
  # Principal IDs obtidos via email lookup
  email_principal_ids = data.azuread_user.users_by_email[*].object_id
  
  # Combinar todas as listas e remover duplicatas
  all_principal_ids = distinct(concat(local.direct_principal_ids, local.email_principal_ids))
}

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

  tags = var.tags

  timeouts {
    create = var.key_vault_timeouts.create
    read   = var.key_vault_timeouts.read
    update = var.key_vault_timeouts.update
    delete = var.key_vault_timeouts.delete
  }
}

 #Role assignments para todos os usuários (emails + principal_ids diretos)
 resource "azurerm_role_assignment" "key_vault_admin" {
  count = length(local.all_principal_ids)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = element(local.all_principal_ids, count.index)

  timeouts {
    create = var.role_assignment_timeouts.create
    read   = var.role_assignment_timeouts.read
    delete = var.role_assignment_timeouts.delete
  }
}