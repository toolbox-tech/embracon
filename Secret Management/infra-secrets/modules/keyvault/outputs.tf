output "key_vault_id" {
  description = "ID do Key Vault criado"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "Nome do Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "URI do Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}