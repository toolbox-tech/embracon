output "managed_identity_client_id" {
  value = azurerm_user_assigned_identity.aks_mi.client_id
}

output "managed_identity_principal_id" {
  value = azurerm_user_assigned_identity.aks_mi.principal_id
}

output "keyvault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "aks_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}