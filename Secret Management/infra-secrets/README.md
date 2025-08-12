<p align="center">
  <img src="../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Módulo Terraform: Azure Key Vault (AKV)

Este módulo facilita a criação e o gerenciamento de um **Azure Key Vault** (AKV) utilizando Terraform, permitindo integração segura de segredos, chaves e certificados em sua infraestrutura como código.

## Funcionalidades

- Criação automatizada de um Azure Key Vault.
- Suporte a gerenciamento de segredos, chaves e certificados.
- Controle de acesso via IAM e políticas de acesso granular.
- Pronto para integração com aplicações e pipelines CI/CD.

## Pré-requisitos

- Conta Azure com permissões para criar recursos.
- [Azure CLI](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli) instalado e autenticado.
- [Terraform](https://www.terraform.io/downloads.html) instalado.

## Uso

```hcl
module "key_vault" {
    source              = "../module"
    resource_group_name = "meu-rg"
    location            = "brazilsouth"
    key_vault_name      = "meukeyvault123"
}

output "key_vault_id" {
    value = module.key_vault.key_vault_id
}

output "key_vault_uri" {
    value = module.key_vault.key_vault_uri
}
```

## Variáveis

| Nome                  | Descrição                        | Obrigatório | Padrão |
|-----------------------|----------------------------------|-------------|--------|
| `name`                | Nome do Key Vault                | Sim         | -      |
| `location`            | Região do recurso                | Sim         | -      |
| `resource_group_name` | Nome do Resource Group           | Sim         | -      |

## Saídas

- `vault_uri`: URI do Key Vault criado.
- `vault_id`: ID do recurso Key Vault.

## Definir subscription_id no Linux
```bash
export TF_VAR_subscription_id=$(az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
```

## Definir subscription_id no Windows
```powershell
$env:TF_VAR_subscription_id = (az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
```

## Observação

A permissão de acesso ao AKV será dada ao usuário utilizado para criar.

---

# Configuração OIDC com Managed Identity para GitHub Actions

## 📋 Configurações Necessárias

### 1. Criar User-Assigned Managed Identity

#### Criar Resource Group (se não existir):
```bash
# Verificar se o Resource Group existe
az group show --name "Embracon" --output table

# Se não existir, criar:
az group create --name "Embracon" --location "brazilsouth"
```

#### Criar Managed Identity:
```bash
# Criar User-Assigned Managed Identity
az identity create \
  --name "github-actions-terraform" \
  --resource-group "Embracon" \
  --location "brazilsouth"

# Obter Client ID da Managed Identity
CLIENT_ID=$(az identity show \
  --name "github-actions-terraform" \
  --resource-group "Embracon" \
  --query clientId -o tsv)
echo "AZURE_CLIENT_ID: $CLIENT_ID"

# Obter Principal ID da Managed Identity
PRINCIPAL_ID=$(az identity show \
  --name "github-actions-terraform" \
  --resource-group "Embracon" \
  --query principalId -o tsv)
echo "Principal ID: $PRINCIPAL_ID"
```

### 2. Configurar Federated Identity Credentials

#### Para a branch feature/secret-management:
```bash
az identity federated-credential create \
  --name "github-feature-secret-management" \
  --identity-name "github-actions-terraform" \
  --resource-group "Embracon" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:toolbox-tech/embracon:ref:refs/heads/feature/secret-management" \
  --audiences "api://AzureADTokenExchange"
```

#### Para workflow_dispatch de qualquer branch (opcional):
```bash
az identity federated-credential create \
  --name "github-workflow-dispatch" \
  --identity-name "github-actions-terraform" \
  --resource-group "Embracon" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:toolbox-tech/embracon:ref:refs/heads/main" \
  --audiences "api://AzureADTokenExchange"
```

### 3. Atribuir Permissões Azure

#### Obter Subscription ID:
```bash
SUBSCRIPTION_ID=$(az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
```

#### Atribuir Roles Necessárias:
```bash
# Role Contributor para criar recursos
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Role User Access Administrator para gerenciar permissões do Key Vault
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "User Access Administrator" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Role Key Vault Administrator (mais específica, opcional)
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Key Vault Administrator" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### 4. GitHub Repository Configuration

#### Secrets (Repository Settings > Secrets and variables > Actions > Secrets):
```
AZURE_CLIENT_ID = <CLIENT_ID da Managed Identity obtido acima>
AZURE_TENANT_ID = <Tenant ID do Azure AD>
```

#### Variables (Repository Settings > Secrets and variables > Actions > Variables):
```
AZURE_SUBSCRIPTION_ID = <Subscription ID da TBX-Sandbox>
```

### 5. Comandos para Obter Informações Necessárias

```bash
# Client ID da Managed Identity
CLIENT_ID=$(az identity show \
  --name "github-actions-terraform" \
  --resource-group "Embracon" \
  --query clientId -o tsv)
echo "AZURE_CLIENT_ID: $CLIENT_ID"

# Tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "AZURE_TENANT_ID: $TENANT_ID"

# Subscription ID
SUBSCRIPTION_ID=$(az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
```

## 🔒 Benefícios do Managed Identity vs App Registration

### **Managed Identity:**
✅ **Mais Simples**: Gerenciamento automático pelo Azure
✅ **Mais Seguro**: Não há secrets para gerenciar
✅ **Integração Nativa**: Melhor integração com recursos Azure
✅ **Auditoria**: Logs centralizados no Azure AD
✅ **Lifecycle**: Gerenciamento automático de ciclo de vida

### **App Registration:**
❌ Requer gerenciamento manual de secrets
❌ Maior superfície de ataque
❌ Complexidade adicional de configuração

## ⚙️ Verificação da Configuração

### Verificar Managed Identity:
```bash
# Listar Managed Identities
az identity list --resource-group "Embracon" --output table

# Verificar federated credentials
az identity federated-credential list \
  --identity-name "github-actions-terraform" \
  --resource-group "Embracon" \
  --output table
```

### Verificar Role Assignments:
```bash
# Verificar roles atribuídas à Managed Identity
az role assignment list \
  --assignee $PRINCIPAL_ID \
  --output table
```

### Testar OIDC Login (no workflow):
```bash
# No workflow, isso deve funcionar sem erros
az account show
az account list
az group list
```

## 🚨 Troubleshooting

### Erro: "AADSTS70021: No matching federated identity record found"
- Verificar se o subject no federated credential está correto
- Subject format: `repo:OWNER/REPO:ref:refs/heads/BRANCH`
- Confirmar que a Managed Identity existe e está no Resource Group correto

### Erro: "Insufficient privileges to complete the operation"
- Verificar se as roles foram atribuídas à Managed Identity
- Confirmar que o Principal ID está correto
- Verificar se as roles incluem "Contributor" e "User Access Administrator"

### Erro: "Context access might be invalid: AZURE_SUBSCRIPTION_ID"
- Garantir que a variável foi criada em Repository Settings > Variables
- Nome deve ser exatamente: `AZURE_SUBSCRIPTION_ID`

### Erro: "The client with object id does not have authorization"
- Aguardar alguns minutos para propagação das permissões
- Verificar se as role assignments foram criadas corretamente
- Confirmar que a subscription ID está correta

### Erro: "Managed Identity not found"
- Verificar se o Resource Group "Embracon" existe
- Confirmar que a Managed Identity foi criada com o nome correto
- Verificar a região (brazilsouth)

## 📝 Resumo das Configurações

| Tipo | Nome | Valor | Local |
|------|------|-------|-------|
| Secret | `AZURE_CLIENT_ID` | Managed Identity Client ID | GitHub Secrets |
| Secret | `AZURE_TENANT_ID` | Azure AD Tenant ID | GitHub Secrets |
| Variable | `AZURE_SUBSCRIPTION_ID` | TBX-Sandbox Subscription ID | GitHub Variables |

## 🔄 Limpeza (se necessário)

### Remover Managed Identity:
```bash
# Remover role assignments
az role assignment delete \
  --assignee $PRINCIPAL_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

az role assignment delete \
  --assignee $PRINCIPAL_ID \
  --role "User Access Administrator" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Remover Managed Identity
az identity delete \
  --name "github-actions-terraform" \
  --resource-group "Embracon"
```

## 🎯 Next Steps

1. **Criar Managed Identity** executando os comandos da seção 1
2. **Configurar Federated Credentials** com os comandos da seção 2
3. **Atribuir Permissões** usando os comandos da seção 3
4. **Configurar GitHub Secrets/Variables** conforme seção 4
5. **Testar o workflow** e verificar logs
6. **Monitorar execução** para garantir autenticação OIDC

## 📊 Comparação: App Registration vs Managed Identity

| Aspecto | App Registration | Managed Identity |
|---------|------------------|------------------|
| **Complexidade** | Alta | Baixa |
| **Gerenciamento** | Manual | Automático |
| **Segurança** | Boa | Excelente |
| **Integração Azure** | Boa | Nativa |
| **Manutenção** | Alta | Mínima |
| **Auditoria** | Complexa | Simples |
| **Recomendado para** | Apps externos | Workloads Azure |

---

# 🚀 Como Usar o Workflow GitHub Actions (akv.yml)

## 📁 Localização do Workflow

O workflow está localizado em: `.github/workflows/akv.yml`

## ⚙️ Configuração do Workflow

### **Triggers:**
- **Manual**: `workflow_dispatch` - Execução manual através da interface do GitHub
- **Working Directory**: `./Secret Management/infra-secrets/resource`

### **Permissões:**
```yaml
permissions:
    id-token: write    # Para autenticação OIDC
    contents: read     # Para leitura do repositório
```

## 🔧 Pré-requisitos para Executar o Workflow

### 1. **Configuração OIDC Completa**
Certifique-se de ter executado todas as etapas da seção OIDC acima:
- ✅ Managed Identity criada
- ✅ Federated Credentials configurados
- ✅ Roles atribuídas
- ✅ Secrets e Variables configurados no GitHub

### 2. **GitHub Secrets Configurados**
Verificar em `Repository Settings > Secrets and variables > Actions`:

**Secrets:**
- `AZURE_CLIENT_ID`: Client ID da Managed Identity
- `AZURE_TENANT_ID`: Tenant ID do Azure AD

**Variables:**
- `AZURE_SUBSCRIPTION_ID`: Subscription ID da TBX-Sandbox

### 3. **Arquivos Terraform Prontos**
Verificar se existem no diretório `Secret Management/infra-secrets/resource/`:
- `main.tf`
- `provider.tf`
- `variables.tf`

## 🎯 Como Executar o Workflow

### **Execução Manual:**

1. **Acesse o GitHub Repository**
   ```
   https://github.com/toolbox-tech/embracon
   ```

2. **Navegue para Actions**
   - Clique na aba "Actions"
   - Selecione "Azure Key Vault Terraform Deployment"

3. **Execute o Workflow**
   - Clique em "Run workflow"
   - Selecione a branch `feature/secret-management`
   - Clique em "Run workflow"

### **Monitoramento da Execução:**

O workflow executará os seguintes steps:
1. **Checkout repository** - Baixa o código
2. **Setup Terraform** - Instala Terraform 1.5.0
3. **Azure Login with OIDC** - Autentica via OIDC
4. **Set Terraform Variables** - Define variáveis de ambiente
5. **Terraform Init** - Inicializa o Terraform
6. **Terraform Validate** - Valida a configuração
7. **Terraform Plan** - Cria plano de execução
8. **Terraform Apply** - Aplica as mudanças (apenas na branch feature/secret-management)

## 📊 Status e Logs

### **Verificar Status:**
- ✅ **Verde**: Execução bem-sucedida
- ❌ **Vermelho**: Falha na execução
- 🟡 **Amarelo**: Em execução

### **Analisar Logs:**
- Clique no job "terraform-deploy"
- Expanda cada step para ver logs detalhados
- Procure por erros ou warnings

## 🚨 Troubleshooting do Workflow

### **Erro: "Error: building AzureRM Client: authenticate to Azure CLI"**
- Verificar se AZURE_CLIENT_ID está correto
- Confirmar AZURE_TENANT_ID
- Verificar Federated Credentials

### **Erro: "Error: Insufficient privileges"**
- Verificar roles da Managed Identity
- Confirmar Principal ID correto
- Aguardar propagação de permissões (até 10 minutos)

### **Erro: "Error: subscription not found"**
- Verificar AZURE_SUBSCRIPTION_ID
- Confirmar nome da subscription 'TBX-Sandbox'
- Verificar se a Managed Identity tem acesso à subscription

### **Erro: "Resource group not found"**
- Verificar se o Resource Group "Embracon" existe
- Confirmar região "brazilsouth"
- Verificar permissões no Resource Group

## 📝 Exemplo de Execução Bem-Sucedida

```bash
# Logs esperados:
✅ Checkout repository
✅ Setup Terraform (1.5.0)
✅ Azure Login with OIDC
✅ Set Terraform Variables
✅ Terraform Init
✅ Terraform Validate
✅ Terraform Plan (X to add, Y to change, Z to destroy)
✅ Terraform Apply (Apply complete! Resources: X added, Y changed, Z destroyed)
```

## 🔄 Workflow Customization

### **Para Adicionar Triggers Automáticos:**
```yaml
on:
  workflow_dispatch:
  push:
    branches:
      - feature/secret-management
    paths:
      - 'Secret Management/infra-secrets/**'
```

### **Para Executar em Múltiplas Branches:**
Remover ou modificar a condição:
```yaml
- name: Terraform Apply
  # if: github.ref == 'refs/heads/feature/secret-management'  # Remover esta linha
  run: terraform apply tfplan
```

## 🎯 Next Steps Após Execução

1. **Verificar Recursos Criados:**
   ```bash
   az keyvault list --resource-group "Embracon" --output table
   ```

2. **Testar Acesso ao Key Vault:**
   ```bash
   az keyvault secret set --vault-name "meukeyvault123" --name "test-secret" --value "test-value"
   az keyvault secret show --vault-name "meukeyvault123" --name "test-secret"
   ```

3. **Monitorar Custos:**
   - Verificar billing no Azure Portal
   - Configurar alertas de custo se necessário

4. **Documentar URIs e IDs:**
   - Salvar Key Vault URI para uso em aplicações
   - Documentar Resource IDs para referência futura