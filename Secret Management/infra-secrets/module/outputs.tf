output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

output "all_principal_ids" {
  value = local.all_principal_ids
  description = "Lista de todos os principal IDs (diretos + obtidos por email)"
}

output "users_from_emails" {
  value = {
    emails = var.users_allowed_emails
    principal_ids = data.azuread_user.users_by_email[*].object_id
    display_names = data.azuread_user.users_by_email[*].display_name
  }
  description = "Informações dos usuários encontrados por email"
}

output "direct_principal_ids" {
  value = var.users_allowed
  description = "Principal IDs fornecidos diretamente"
}