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

variable "users_allowed" {
  description = "Lista de Object IDs dos usuários permitidos a acessar o Key Vault"
  type        = list(string)
  default     = []
}

variable "users_allowed_emails" {
  description = "Lista de emails dos usuários permitidos a acessar o Key Vault (user principal names)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags a serem aplicadas ao Key Vault"
  type        = map(string)
  default     = {}
}

variable "key_vault_timeouts" {
  description = "Configurações de timeout para o Key Vault"
  type = object({
    create = optional(string, "30m")
    read   = optional(string, "30m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default = {
    create = "30m"
    read   = "30m"
    update = "30m"
    delete = "30m"
  }
}

variable "role_assignment_timeouts" {
  description = "Configurações de timeout para as atribuições de role"
  type = object({
    create = optional(string, "10m")
    read   = optional(string, "5m")
    delete = optional(string, "10m")
  })
  default = {
    create = "10m"
    read   = "5m"
    delete = "10m"
  }
}