# 🔑 Como Buscar Principal ID pelo Email no Terraform

## 📋 Cenário
Você precisa dar acesso ao Key Vault para usuários, mas só tem o **email** deles, não o `principal_id` (Object ID).

## 🎯 Solução Implementada

### **1. Data Source para buscar usuários por email:**
```terraform
# Buscar usuários do Azure AD pelos emails
data "azuread_user" "users_by_email" {
  count = length(var.users_allowed_emails)
  user_principal_name = element(var.users_allowed_emails, count.index)
}
```

### **2. Locals para combinar principal_ids diretos e obtidos por email:**
```terraform
locals {
  # Principal IDs diretos da variável users_allowed
  direct_principal_ids = var.users_allowed
  
  # Principal IDs obtidos via email lookup
  email_principal_ids = data.azuread_user.users_by_email[*].object_id
  
  # Combinar todas as listas e remover duplicatas
  all_principal_ids = distinct(concat(local.direct_principal_ids, local.email_principal_ids))
}
```

### **3. Role Assignment usando todos os principal_ids:**
```terraform
resource "azurerm_role_assignment" "key_vault_admin" {
  count = length(local.all_principal_ids)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = element(local.all_principal_ids, count.index)
}
```

## 🚀 Como Usar

### **Opção 1: Apenas emails**
```terraform
module "key_vault" {
  source = "./module"
  
  resource_group_name = "rg-keyvault-prod"
  location           = "East US"
  key_vault_name     = "kv-embracon-prod"
  
  # Usuários por email
  users_allowed_emails = [
    "joao.silva@embracon.com.br",
    "maria.santos@embracon.com.br",
    "admin@embracon.com.br"
  ]
}
```

### **Opção 2: Apenas principal_ids**
```terraform
module "key_vault" {
  source = "./module"
  
  resource_group_name = "rg-keyvault-prod"
  location           = "East US"
  key_vault_name     = "kv-embracon-prod"
  
  # Usuários por Object ID direto
  users_allowed = [
    "12345678-1234-1234-1234-123456789012",
    "87654321-4321-4321-4321-210987654321"
  ]
}
```

### **Opção 3: Misto (emails + principal_ids)**
```terraform
module "key_vault" {
  source = "./module"
  
  resource_group_name = "rg-keyvault-prod"
  location           = "East US"
  key_vault_name     = "kv-embracon-prod"
  
  # Usuários por email
  users_allowed_emails = [
    "joao.silva@embracon.com.br",
    "maria.santos@embracon.com.br"
  ]
  
  # Usuários por Object ID direto (service principals, etc)
  users_allowed = [
    "12345678-1234-1234-1234-123456789012"  # Service Principal
  ]
}
```

## 🔧 Detalhes Técnicos

### **Data Source `azuread_user`:**
- **Função**: Busca informações de usuário no Azure AD
- **Input**: `user_principal_name` (email)
- **Output**: `object_id` (principal_id), `display_name`, etc.

### **Função `element()`:**
- **Função**: Acessa elemento específico de uma lista
- **Sintaxe**: `element(lista, índice)`
- **Exemplo**: `element(var.users_allowed_emails, count.index)`

### **Locals block:**
- **Função**: Define valores calculados locais
- **Vantagem**: Evita repetir lógica complexa
- **Uso**: Combinar e processar dados

### **Função `distinct()`:**
- **Função**: Remove duplicatas de uma lista
- **Importante**: Evita criar role assignments duplicados

### **Função `concat()`:**
- **Função**: Combina múltiplas listas em uma
- **Exemplo**: `concat(lista1, lista2, lista3)`

## ⚠️ Considerações Importantes

### **1. Permissões necessárias:**
```bash
# A service principal/usuário executando o Terraform precisa de:
# - Directory.Read.All no Azure AD
# - Contributor no Resource Group
```

### **2. User Principal Name vs Email:**
```terraform
# ✅ Correto - User Principal Name
user_principal_name = "joao.silva@embracon.com.br"

# ❌ Incorreto - Display Name
user_principal_name = "João Silva"
```

### **3. Tratamento de erro:**
```terraform
# Se usuário não existir, o Terraform falhará
# Considere validar emails antes de aplicar
```

## 🎯 Exemplo Completo de Uso

```terraform
# main.tf
module "key_vault_prod" {
  source = "../modules/key-vault"
  
  resource_group_name = "rg-keyvault-prod"
  location           = "East US"
  key_vault_name     = "kv-embracon-prod-001"
  
  # Administradores por email
  users_allowed_emails = [
    "admin@embracon.com.br",
    "devops@embracon.com.br",
    "security@embracon.com.br"
  ]
  
  # Service Principals por Object ID
  users_allowed = [
    data.azurerm_client_config.current.object_id,  # Current user
    "a1b2c3d4-5678-90ab-cdef-1234567890ab"         # CI/CD Service Principal
  ]
  
  # Configurações adicionais
  sku_name                   = "standard"
  soft_delete_retention_days = 30
  purge_protection_enabled   = true
}

# Outputs úteis
output "key_vault_id" {
  value = module.key_vault_prod.key_vault_id
}

output "key_vault_url" {
  value = module.key_vault_prod.key_vault_uri
}

output "assigned_users" {
  value = {
    emails = var.users_allowed_emails
    principal_ids = var.users_allowed
    total_users = length(module.key_vault_prod.all_principal_ids)
  }
}
```

## 🚀 Comandos para Aplicar

```bash
# 1. Inicializar Terraform
terraform init

# 2. Planejar mudanças
terraform plan

# 3. Aplicar mudanças
terraform apply

# 4. Verificar recursos criados
az keyvault show --name kv-embracon-prod-001 --resource-group rg-keyvault-prod
```

## 🔍 Troubleshooting

### **Erro: "User not found"**
```bash
# Verificar se o email existe no Azure AD
az ad user show --id "joao.silva@embracon.com.br"
```

### **Erro: "Insufficient privileges"**
```bash
# Verificar permissões da service principal
az ad sp show --id <service-principal-id> --query "appRoles"
```

### **Erro: "Principal ID already has role assignment"**
```bash
# O distinct() deveria evitar isso, mas se acontecer:
terraform import azurerm_role_assignment.key_vault_admin[0] "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/.../providers/Microsoft.Authorization/roleAssignments/..."
```

## 💡 Dicas Avançadas

### **1. Validação de emails:**
```terraform
variable "users_allowed_emails" {
  description = "Lista de emails dos usuários"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for email in var.users_allowed_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "Todos os emails devem ter formato válido."
  }
}
```

### **2. Diferentes roles por tipo de usuário:**
```terraform
# Admins completos
resource "azurerm_role_assignment" "key_vault_admin" {
  count = length(var.admin_emails)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_user.admins[count.index].object_id
}

# Usuários com acesso limitado
resource "azurerm_role_assignment" "key_vault_user" {
  count = length(var.user_emails)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_user.users[count.index].object_id
}
```

### **3. Output dos usuários processados:**
```terraform
output "processed_users" {
  value = {
    emails_found = data.azuread_user.users_by_email[*].user_principal_name
    object_ids = data.azuread_user.users_by_email[*].object_id
    display_names = data.azuread_user.users_by_email[*].display_name
  }
}
```

🎉 **Pronto!** Agora você pode usar emails para dar acesso ao Key Vault de forma flexível e segura!
