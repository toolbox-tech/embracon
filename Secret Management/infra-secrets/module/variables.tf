variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização do Resource Group"
  type        = string
}

variable "key_vault_name" {
  description = "Nome do Key Vault"
  type        = string
}

# variable "tenant_id" {
#   description = "Tenant ID do Azure AD"
#   type        = string
# }

variable "sku_name" {
  description = "SKU do Key Vault (standard ou premium)"
  type        = string
  default     = "standard"
}

# variable "admin_object_id" {
#   description = "Object ID do administrador para access policy"
#   type        = string
# }

variable "soft_delete_retention_days" {
  description = "Número de dias para retenção de soft delete no Key Vault"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Habilita ou não a proteção contra purge no Key Vault"
  type        = bool
  default     = true
}

variable "key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}

variable "storage_permissions" {
  type        = list(string)
  description = "List of storage permissions."
  default     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
}

variable "certificate_permissions" {
  type        = list(string)
  description = "List of certificate permissions."
  default     = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
}

variable "users_allowed" {
  description = "Lista de Object IDs dos usuários permitidos a acessar o Key Vault"
  type        = list(string)
  default     = []
}