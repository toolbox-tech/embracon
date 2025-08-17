<p align="center">
  <img src="../../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Módulo Terraform - Azure Key Vault

Este módulo Terraform cria e configura um Azure Key Vault com as melhores práticas de segurança implementadas.

## 📋 Funcionalidades

- Criação de Azure Key Vault com configurações de segurança
- Habilitação automática de RBAC (Role-Based Access Control)
- Configuração de soft delete e purge protection
- Atribuição automática de permissões para usuários específicos
- Suporte a diferentes SKUs (Standard/Premium)

## 🏗️ Recursos Criados

Este módulo cria os seguintes recursos no Azure:

- **Azure Key Vault**: Cofre principal para armazenamento de segredos
- **Role Assignments**: Atribuições de função "Key Vault Administrator" para usuários específicos

## 📖 Como Usar

### Uso Básico

```hcl
module "key_vault" {
  source              = "./module"
  resource_group_name = "meu-resource-group"
  location            = "brazilsouth"
  key_vault_name      = "meu-keyvault-unico"
  users_allowed       = ["object-id-usuario-1", "object-id-usuario-2"]
}
```

### Uso Completo com Todas as Variáveis

```hcl
module "key_vault" {
  source                     = "./module"
  resource_group_name        = "meu-resource-group"
  location                   = "brazilsouth"
  key_vault_name             = "meu-keyvault-unico"
  sku_name                   = "premium"
  soft_delete_retention_days = 14
  purge_protection_enabled   = true
  users_allowed              = [
    "29958a68-e230-4b9b-b432-582e7c46bcef",
    "d6369133-a12b-4f42-bd17-e136c620d630"
  ]
  
  # Permissões customizadas (opcional)
  key_permissions = ["Get", "List", "Create", "Delete"]
  secret_permissions = ["Get", "List", "Set", "Delete"]
}
```

## 🔧 Variáveis de Entrada

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|-------------|
| `resource_group_name` | Nome do Resource Group onde o Key Vault será criado | `string` | - | ✅ |
| `location` | Região do Azure onde o Key Vault será criado | `string` | - | ✅ |
| `key_vault_name` | Nome único do Key Vault (deve ser globalmente único) | `string` | - | ✅ |
| `users_allowed` | Lista de Object IDs dos usuários com acesso ao Key Vault | `list(string)` | `[]` | ❌ |
| `sku_name` | SKU do Key Vault | `string` | `"standard"` | ❌ |
| `soft_delete_retention_days` | Dias de retenção para soft delete | `number` | `7` | ❌ |
| `purge_protection_enabled` | Habilita proteção contra purge | `bool` | `true` | ❌ |
| `key_permissions` | Lista de permissões para chaves | `list(string)` | Ver padrões | ❌ |
| `secret_permissions` | Lista de permissões para segredos | `list(string)` | Ver padrões | ❌ |
| `storage_permissions` | Lista de permissões para storage | `list(string)` | Ver padrões | ❌ |
| `certificate_permissions` | Lista de permissões para certificados | `list(string)` | Ver padrões | ❌ |

### Variáveis do Provider

| Nome | Descrição | Tipo | Obrigatório |
|------|-----------|------|-------------|
| `subscription_id` | ID da subscription do Azure | `string` | ✅ |

### Valores Padrão das Permissões

**Key Permissions (Padrão):**
```
["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
```

**Secret Permissions (Padrão):**
```
["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
```

## 📤 Outputs

| Nome | Descrição |
|------|-----------|
| `key_vault_id` | ID completo do Azure Key Vault |
| `key_vault_uri` | URI do Key Vault para acesso via SDK/API |

## 🔒 Configurações de Segurança

Este módulo implementa as seguintes práticas de segurança:

- **RBAC Habilitado**: Utiliza Azure RBAC em vez de Access Policies
- **Soft Delete**: Proteção contra exclusão acidental (7-90 dias)
- **Purge Protection**: Proteção contra exclusão permanente
- **Disk Encryption**: Habilitado para uso com Azure Disk Encryption
- **Tenant ID Automático**: Obtido automaticamente do contexto atual

## 📋 Pré-requisitos

1. **Terraform**: Versão >= 1.0
2. **Azure Provider**: Versão 4.38.1 (conforme especificado)
3. **Azure CLI**: Configurado e autenticado
4. **Subscription ID**: ID da subscription do Azure onde os recursos serão criados
5. **Permissões Azure**: O usuário/service principal deve ter:
   - Permissão para criar Key Vaults
   - Permissão para criar Role Assignments
   - Acesso ao Resource Group especificado
   - Acesso à subscription especificada

## 🚀 Como Obter Informações Necessárias

### Object IDs dos Usuários

Para obter o Object ID de um usuário do Azure AD:

```bash
# Via Azure CLI
az ad user show --id "usuario@dominio.com" --query objectId -o tsv

# Para o usuário atual
az ad signed-in-user show --query objectId -o tsv

# Para listar usuários
az ad user list --query "[].{DisplayName:displayName, ObjectId:objectId}" -o table
```

### Subscription ID

Para obter o ID da subscription do Azure:

```bash
# Listar todas as subscriptions
az account list --query "[].{Name:name, SubscriptionId:id}" -o table

# Obter subscription por nome específico
az account list --query "[?name=='Nome da Assinatura'].id" --output tsv

# Obter subscription atual
az account show --query id -o tsv
```

### Definir subscription_id como Variável de Ambiente

#### No Linux/macOS
```bash
export TF_VAR_subscription_id=$(az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
```

#### No Windows (PowerShell)
```powershell
$env:TF_VAR_subscription_id = (az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
```

> **Nota**: Substitua `'TBX-Sandbox'` pelo nome da sua subscription do Azure.

## 📝 Exemplo Completo de Implementação

```hcl
# provider.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.38.1"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  # Para ver a subscrição rode o comando az account list --query "[?name=='Nome da Assinatura'].id" --output tsv
  features {}
}

# variables.tf
variable "subscription_id" {
  description = "ID da subscription do Azure"
  type        = string
}

# main.tf
module "key_vault" {
  source              = "../module"
  resource_group_name = "Embracon"
  location            = "brazilsouth"
  key_vault_name      = "embracon-kv-prod-001"
  users_allowed       = [
    "29958a68-e230-4b9b-b432-582e7c46bcef",  # Usuário Admin
    "d6369133-a12b-4f42-bd17-e136c620d630"   # Usuário DevOps
  ]
}

# outputs.tf
output "key_vault_id" {
  value       = module.key_vault.key_vault_id
  description = "ID do Key Vault criado"
}

output "key_vault_uri" {
  value       = module.key_vault.key_vault_uri
  description = "URI do Key Vault criado"
  sensitive   = true
}
```

### Usando Variável de Ambiente (Recomendado)

Defina a variável de ambiente antes de executar o Terraform:

#### Linux/macOS:
```bash
export TF_VAR_subscription_id=$(az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
terraform plan
terraform apply
```

#### Windows (PowerShell):
```powershell
$env:TF_VAR_subscription_id = (az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
terraform plan
terraform apply
```

### terraform.tfvars (alternativa)

```hcl
subscription_id = "12345678-1234-1234-1234-123456789012"
```

## ⚠️ Considerações Importantes

1. **Nome Único**: O nome do Key Vault deve ser globalmente único no Azure
2. **Soft Delete**: Uma vez habilitado, não pode ser desabilitado
3. **Purge Protection**: Recomendado para ambientes de produção
4. **Custos**: SKU Premium tem custos adicionais mas oferece HSM
5. **Permissões**: O módulo atribui role "Key Vault Administrator" - ajuste conforme necessário

## 🔄 Versionamento

Este módulo segue o versionamento semântico. Consulte as releases para mudanças específicas.

## 📞 Suporte

Para dúvidas ou problemas:
- Abra uma issue no repositório
- Consulte a documentação oficial do [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/)
- Verifique a documentação do [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença [MIT](LICENSE).

---

<p align="center">
  <strong>🚀 Secret Management 🛡️</strong><br>
    <em>📦 Terraform Module</em>
</p>
