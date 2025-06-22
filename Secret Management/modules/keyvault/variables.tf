variable "key_vault_name" {
  description = "Nome do Azure Key Vault"
  type        = string
}

variable "location" {
  description = "Localização do recurso"
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "purge_protection_enabled" {
  description = "Habilita purge protection no Key Vault"
  type        = bool
  default     = true
}

variable "secrets" {
  description = "Mapa de segredos a serem criados no Key Vault"
  type        = map(string)
  default     = {}
}

variable "diagnostics_storage_account_id" {
  description = "ID da Storage Account para logs de diagnóstico"
  type        = string
}

variable "github_actions_object_id" {
  description = "Object ID do GitHub Actions para acesso ao Key Vault"
  type        = string
}

variable "managed_identities" {
  description = "Lista de Object IDs das Managed Identities com acesso ao Key Vault"
  type        = list(string)
  default     = []
}