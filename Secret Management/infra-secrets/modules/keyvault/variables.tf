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

variable "github_actions_object_id" {
  description = "Object ID do GitHub Actions para acesso ao Key Vault"
  type        = string
  default     = null
}

variable "managed_identities" {
  description = "Lista de Object IDs das Managed Identities com acesso ao Vault"
  type        = list(string)
  default     = []
}

variable "user_access_policies" {
  description = "Lista de políticas de acesso para usuários/grupos"
  type = list(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}

variable "diagnostics_storage_account_id" {
  description = "ID do Storage Account para logs de diagnóstico"
  type        = string
  default     = null
}