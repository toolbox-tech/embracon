# Gerenciamento de Azure Key Vault com Terraform e GitHub Actions

## Observações

Ao conceder uma política de acesso a um Key Vault, você pode definir permissões específicas para segredos, chaves e certificados de forma independente. Sempre revise cuidadosamente as permissões concedidas e aplique o princípio do menor privilégio, garantindo que cada identidade tenha acesso apenas ao necessário para sua função.

A política de acesso é uma por Key Vault, e não por segredo. Portanto, ao conceder acesso a um usuário ou grupo, você está concedendo acesso a todos os segredos dentro do Key Vault. Isso significa que não é possível restringir o acesso a um único segredo ou a um grupo específico de segredos.

Por padrão, o acesso ao Key Vault é permitido de qualquer rede, mas você pode configurar regras de firewall para restringir o acesso.

É necessário habilitar o monitoramento (logging e metrics) para o Key Vault para garantir que todas as operações sejam auditadas.

## Estrutura do Repositório Terraform

```
infra-secrets/
├── .github/
│   └── workflows/
│       ├── terraform-apply.yml
│       └── terraform-plan.yml
├── modules/
│   └── keyvault/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── access_policy.tf
│       └── diagnostics.tf
└── README.md
```

## Módulo Terraform para Azure Key Vault

### Recursos Principais (main.tf)

```hcl
# modules/keyvault/main.tf
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = var.purge_protection_enabled

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Recover", "Backup", "Restore"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]
  }

  tags = var.tags
}
```

### Políticas de Acesso (access_policy.tf)

```hcl
# modules/keyvault/access_policy.tf
resource "azurerm_key_vault_access_policy" "github_actions" {
  count = var.github_actions_object_id != null ? 1 : 0

  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.github_actions_object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]
}

resource "azurerm_key_vault_access_policy" "managed_identities" {
  for_each = toset(var.managed_identities)

  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_key_vault_access_policy" "users" {
  for_each = { for idx, policy in var.user_access_policies : idx => policy }

  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.object_id

  key_permissions         = lookup(each.value, "key_permissions", [])
  secret_permissions      = lookup(each.value, "secret_permissions", [])
  certificate_permissions = lookup(each.value, "certificate_permissions", [])
}
```

### Variáveis (variables.tf)

```hcl
# modules/keyvault/variables.tf
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
```

### Outputs (outputs.tf)

```hcl
# modules/keyvault/outputs.tf
output "key_vault_id" {
  description = "ID do Key Vault criado"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "Nome do Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "URI do Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}
```

## Como Usar o Módulo

### Exemplo de uso em environments/dev/main.tf

```hcl
module "key_vault" {
  source = "../../modules/keyvault"

  key_vault_name          = "kv-dev-myapp"
  resource_group_name     = var.resource_group_name
  location                = var.location
  purge_protection_enabled = false

  # Acesso para GitHub Actions
  github_actions_object_id = var.github_actions_object_id

  # Managed Identities com acesso de leitura
  managed_identities = [
    var.app_managed_identity_id
  ]

  # Usuários/grupos com acesso específico
  user_access_policies = [
    {
      object_id = var.dev_team_group_id
      secret_permissions = ["Get", "List", "Set"]
    },
    {
      object_id = var.security_team_group_id
      secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
      key_permissions = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "MyApp"
  }
}
```

## Configuração de CI/CD com GitHub Actions

### terraform-plan.yml

```yaml
name: Terraform Plan
on:
  pull_request:
    branches: [main]
    paths: ['environments/**', 'modules/**']

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    environment: dev

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Terraform Init
        run: terraform init
        working-directory: ./environments/dev

      - name: Terraform Plan
        run: terraform plan -var-file="terraform.tfvars"
        working-directory: ./environments/dev
```

### terraform-apply.yml

```yaml
name: Terraform Apply
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Ambiente (dev, hml, prod)'
        required: true
        default: 'dev'

jobs:
  terraform-apply:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Terraform Init
        run: terraform init
        working-directory: ./environments/${{ inputs.environment }}

      - name: Terraform Apply
        run: terraform apply -auto-approve -var-file="terraform.tfvars"
        working-directory: ./environments/${{ inputs.environment }}
```

## Boas Práticas Implementadas

1. **Segurança**:
   - Políticas de acesso granulares por tipo de recurso (segredos, chaves, certificados)
   - Princípio do menor privilégio
   - Soft delete habilitado por padrão
   - Proteção contra purge configurável

2. **Gerenciamento**:
   - Separação clara entre diferentes tipos de identidades (usuários, managed identities, service principals)
   - Configuração flexível através de variáveis
   - Suporte a múltiplos ambientes

3. **Auditoria**:
   - Logs de diagnóstico configuráveis
   - Rastreamento de todas as operações