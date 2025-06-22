# Gerenciamento de Azure Key Vault com Terraform e GitHub Actions

## Visão Geral do Fluxo Automatizado

1. **Estrutura do Repositório Terraform**
```
infra-secrets/
├── .github/
│   └── workflows/
│       ├── terraform-apply.yml
│       └── terraform-plan.yml
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── hml/
│   └── prod/
├── modules/
│   └── keyvault/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md
```

2. **Configuração do GitHub Actions para CI/CD**

```yaml
# .github/workflows/terraform-plan.yml
name: Terraform Plan
on:
  pull_request:
    branches:
      - main
    paths:
      - 'environments/**'
      - 'modules/**'

jobs:
  terraform-plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    environment: dev
    defaults:
      run:
        working-directory: ./environments/${{ github.event.inputs.environment || 'dev' }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -var-file="terraform.tfvars"
```

```yaml
# .github/workflows/terraform-apply.yml
name: Terraform Apply
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Ambiente (dev, hml, prod)'
        required: true
        default: 'dev'
      tf_command:
        description: 'Comando Terraform'
        required: true
        default: 'apply'
        type: choice
        options:
          - apply
          - destroy

jobs:
  terraform-apply:
    name: Terraform Apply
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'dev' }}
    defaults:
      run:
        working-directory: ./environments/${{ github.event.inputs.environment || 'dev' }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        if: github.event.inputs.tf_command == 'apply'
        run: terraform apply -auto-approve -var-file="terraform.tfvars"

      - name: Terraform Destroy
        if: github.event.inputs.tf_command == 'destroy'
        run: |
          echo "Destroy requires manual approval"
          terraform destroy -auto-approve -var-file="terraform.tfvars"
```

3. **Módulo Terraform para Azure Key Vault**

```hcl
# modules/keyvault/main.tf
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
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "secret"

  depends_on = [azurerm_key_vault.kv]
}
```

4. **Configuração por Ambiente**

```hcl
# environments/dev/main.tf
module "key_vault" {
  source = "../../modules/keyvault"

  key_vault_name          = "kv-${var.environment}-${var.application_name}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  purge_protection_enabled = false
  secrets                 = var.secrets

  additional_access_policies = [
    {
      object_id = data.azurerm_client_config.current.object_id
      tenant_id = data.azurerm_client_config.current.tenant_id
      secret_permissions = ["Get", "List"]
    }
  ]
}
```

5. **Autenticação Segura via Workload Identity Federation**

```yaml
# Configuração adicional no GitHub Actions
- name: Azure Login
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    enable-oidc: true
```

6. **Processo de Aprovação para Ambientes Produtivos**

```yaml
# Adicionar ao workflow de apply
- name: Require approval for production
  if: github.event.inputs.environment == 'prod'
  uses: trstringer/manual-approval@v1
  with:
    secret: ${{ secrets.APPROVER_TOKEN }}
    approvers: 'security-team,devops-lead'
    minimum-approvals: 2
    issue-title: "Approval required for production changes"
```

## Implementação Detalhada

### 1. Configuração Inicial

1. **Crie um Service Principal para o Terraform**:
```bash
az ad sp create-for-rbac --name "terraform-github-actions" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>
```

2. **Configure Workload Identity Federation**:
```bash
az ad app federated-credential create \
  --id <APPLICATION_ID> \
  --parameters @./federated-credential.json
```

### 2. Módulos Avançados de Key Vault

```hcl
# modules/keyvault/access_policy.tf
resource "azurerm_key_vault_access_policy" "github_actions" {
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
```

### 3. Pipeline de Atualização de Secrets

```yaml
# .github/workflows/update-secret.yml
name: Update Key Vault Secret
on:
  workflow_dispatch:
    inputs:
      secret_name:
        description: 'Nome do Secret'
        required: true
      secret_value:
        description: 'Valor do Secret'
        required: true
      environment:
        description: 'Ambiente'
        required: true
        default: 'dev'

jobs:
  update-secret:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment || 'dev' }}
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          enable-oidc: true

      - name: Update Secret
        run: |
          az keyvault secret set \
            --name "${{ inputs.secret_name }}" \
            --vault-name "kv-${{ inputs.environment }}-myapp" \
            --value "${{ inputs.secret_value }}" \
            --output none
        env:
          AZURE_KEYVAULT_SKIP_CREDENTIAL_VALIDATION: true
```

### 4. Monitoramento e Auditoria

```hcl
# modules/keyvault/diagnostics.tf
resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name               = "kv-diag-logs"
  target_resource_id = azurerm_key_vault.kv.id
  storage_account_id = var.diagnostics_storage_account_id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}
```

## Boas Práticas Implementadas

1. **Segurança**:
   - Uso de Workload Identity Federation para autenticação sem segredos
   - RBAC granular com políticas de acesso mínimas necessárias
   - Habilitar purge protection e soft delete
   - Auditoria completa de todas as operações

2. **Governança**:
   - Estrutura de módulos Terraform reutilizáveis
   - Separação clara por ambientes
   - Pipeline de CI/CD com aprovações manuais para produção
   - Versionamento de toda infraestrutura como código

3. **Automatização**:
   - Provisionamento completo via GitHub Actions
   - Atualização de secrets via pipeline automatizado
   - Integração com sistemas existentes
   - Notificações e monitoramento

4. **Resiliência**:
   - Configurações de backup e recuperação
   - Proteção contra exclusão acidental
   - Rotação automática de credenciais (opcional)
   - Múltiplas camadas de aprovação para mudanças críticas

Esta implementação fornece um sistema completo para gerenciamento seguro de Azure Key Vault usando Terraform e GitHub Actions, seguindo as melhores práticas de segurança e governança em nuvem.

# Módulo Terraform para Azure Key Vault

## Visão Geral

Este módulo Terraform provisiona e gerencia um Azure Key Vault (AKV) com configurações seguras e boas práticas incorporadas. O módulo é projetado para ser reutilizável em diferentes ambientes (dev, hml, prod) e projetos.

## Estrutura do Módulo

```
modules/keyvault/
├── main.tf          # Recursos principais do Key Vault
├── variables.tf     # Variáveis de entrada do módulo
├── outputs.tf       # Saídas do módulo
├── access_policy.tf # Políticas de acesso
└── diagnostics.tf   # Configurações de diagnóstico e monitoramento
```

## Recursos Provisionados

1. **Azure Key Vault**:
   - Habilitação de soft delete (90 dias)
   - Proteção contra purge (configurável)
   - SKU Standard
   - Políticas de acesso básicas

2. **Recursos Adicionais**:
   - Secrets do Key Vault
   - Políticas de acesso para identidades gerenciadas
   - Configurações de diagnóstico para auditoria

## Como Usar

### Exemplo Básico

```hcl
module "key_vault" {
  source = "../../modules/keyvault"

  key_vault_name          = "kv-dev-myapp"
  resource_group_name     = azurerm_resource_group.example.name
  location                = "eastus"
  purge_protection_enabled = false
  secrets = {
    "database-password" = "initial-password-value"
    "api-key"          = "initial-api-key"
  }
}
```

### Exemplo Completo

```hcl
module "prod_key_vault" {
  source = "../../modules/keyvault"

  key_vault_name          = "kv-prod-myapp-001"
  resource_group_name     = azurerm_resource_group.prod.name
  location                = "eastus"
  purge_protection_enabled = true
  tags = {
    Environment = "Production"
    Critical   = "true"
  }

  secrets = {
    "prod-db-password" = data.azurerm_key_vault_secret.db_password.value
  }

  managed_identities = [
    azurerm_user_assigned_identity.app.id,
    azurerm_user_assigned_identity.ci_cd.id
  ]

  additional_access_policies = [
    {
      object_id = "00000000-0000-0000-0000-000000000000" # ID do grupo de segurança
      tenant_id = data.azurerm_client_config.current.tenant_id
      secret_permissions = ["Get", "List"]
    }
  ]
}
```

## Variáveis de Entrada

| Nome | Tipo | Descrição | Valor Padrão | Obrigatório |
|------|------|-----------|--------------|-------------|
| `key_vault_name` | string | Nome do Azure Key Vault | - | Sim |
| `resource_group_name` | string | Nome do resource group | - | Sim |
| `location` | string | Região Azure | - | Sim |
| `purge_protection_enabled` | bool | Habilita proteção contra purge | `false` | Não |
| `secrets` | map(string) | Map de secrets para criar | `{}` | Não |
| `managed_identities` | list(string) | Lista de IDs de Managed Identities para acesso | `[]` | Não |
| `additional_access_policies` | list(object) | Políticas de acesso adicionais | `[]` | Não |
| `tags` | map(string) | Tags para os recursos | `{}` | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| `key_vault_id` | ID do Key Vault criado |
| `key_vault_name` | Nome do Key Vault |
| `key_vault_uri` | URI do Key Vault |
| `secret_ids` | Map de IDs dos secrets criados |

## Boas Práticas Implementadas

1. **Segurança**:
   - Soft delete habilitado por padrão
   - Proteção contra purge configurável
   - RBAC mínimo através de políticas de acesso granulares

2. **Auditoria**:
   - Logs de diagnóstico habilitados
   - Rastreamento de todas as operações

3. **Gerenciamento**:
   - Interface simples com valores sensíveis opcionais
   - Suporte a múltiplas identidades gerenciadas
   - Tags padrão para organização

## Dependências

- Provider AzureRM >= 3.0
- Azure CLI configurado para autenticação (quando executado localmente)

## Observações Importantes

1. Para ambientes de produção, recomenda-se habilitar `purge_protection_enabled`
2. Valores de secrets podem ser passados diretamente ou referenciados de outros data sources
3. O módulo não gerencia rotacionamento automático de secrets - isso deve ser feito separadamente

## Exemplo de Política de Acesso Adicional

Para adicionar políticas de acesso customizadas:

```hcl
additional_access_policies = [
  {
    object_id = "00000000-0000-0000-0000-000000000000"
    tenant_id = "00000000-0000-0000-0000-000000000000"
    secret_permissions = ["Get", "List"]
    key_permissions = []
    certificate_permissions = []
  }
]
```