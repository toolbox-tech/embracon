module "key_vault" {
  source              = "../module"
  resource_group_name = "Embracon"
  location            = "brazilsouth"
  key_vault_name      = "meukeyvault123"
  # Deve ser colocado Object ID do usuário a ser adicionado.
  users_allowed       = ["29958a68-e230-4b9b-b432-582e7c46bcef","d6369133-a12b-4f42-bd17-e136c620d630"]
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}