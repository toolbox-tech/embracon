module "key_vault" {
  source              = "../module"
  resource_group_name = "Embracon"
  location            = "brazilsouth"
  key_vault_name      = "meukeyvault123"
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}