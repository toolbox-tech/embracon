module "key_vault" {
  source              = "../module"
  resource_group_name = "Embracon"
  location            = "brazilsouth"
  key_vault_name      = "meukeyvault123"
  # Deve ser colocado Object ID do usuário a ser adicionado.
  # users_allowed       = ["29958a68-e230-4b9b-b432-582e7c46bcef","d6369133-a12b-4f42-bd17-e136c620d630"]
  users_allowed_emails = [
    "marcelo.buzzetti@joaopereiratbxtech.onmicrosoft.com"
  ]

  tags = {
    Environment = "Development"
    Project     = "Infra"
    Owner       = "Toolbox"
  }

  # Personalizar timeouts se necessário (opcional)
  key_vault_timeouts = {
    create = "45m"  # Timeout maior para criação
    read   = "30m"
    update = "30m"
    delete = "30m"
  }

  role_assignment_timeouts = {
    create = "15m"  # Timeout maior para role assignments
    read   = "5m"
    delete = "10m"
  }
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "all_principal_ids" {
  value = module.key_vault.all_principal_ids
  description = "Lista de todos os principal IDs (diretos + obtidos por email)"
}

output "users_from_emails" {
  value = module.key_vault.users_from_emails
  description = "Informações dos usuários encontrados por email"
}

output "direct_principal_ids" {
  value = module.key_vault.direct_principal_ids
  description = "Principal IDs fornecidos diretamente"
}