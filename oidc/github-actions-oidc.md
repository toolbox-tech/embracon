# Configuração de OIDC para GitHub Actions no Azure

Este guia explica como configurar a autenticação OIDC (OpenID Connect) entre GitHub Actions e o Azure para uma conexão mais segura e sem credenciais armazenadas.

## 📝 Índice

1. [Benefícios do OIDC](#benefícios-do-oidc)
2. [Pré-requisitos](#pré-requisitos)
3. [Configuração no Azure](#configuração-no-azure)
4. [Configuração no GitHub](#configuração-no-github)
5. [Testando a Configuração](#testando-a-configuração)
6. [Solução de Problemas](#solução-de-problemas)

## Benefícios do OIDC

- **Sem credenciais armazenadas**: Elimina a necessidade de armazenar segredos de longa duração
- **Tokens de curta duração**: Tokens são gerados sob demanda e têm validade limitada
- **Maior segurança**: Reduz o risco de exposição de credenciais
- **Autenticação federada**: Facilita o gerenciamento de identidades entre serviços

## Pré-requisitos

- Acesso de administrador ao Azure Portal
- Permissões para criar aplicativos no Azure AD e atribuir funções
- Acesso para configurar segredos no GitHub

## Configuração no Azure

### 1. Criar uma Identidade Gerenciada no Azure

```bash
# Definir variáveis
SUBSCRIPTION_ID="sua-subscription-id"
RESOURCE_GROUP="embracon-infra"
LOCATION="brazilsouth"
IDENTITY_NAME="github-actions-embracon"

# Criar identidade gerenciada
az identity create --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

# Obter Client ID da identidade criada
CLIENT_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --query clientId -o tsv)
```

### 2. Atribuir permissões à Identidade

```bash
# Obter ID do ACR
ACR_ID=$(az acr show --name embraconacr --resource-group $RESOURCE_GROUP --query id -o tsv)

# Conceder permissão de AcrPush
az role assignment create --assignee $CLIENT_ID --scope $ACR_ID --role AcrPush
```

### 3. Configurar Credenciais Federadas

```bash
# Obter tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)

# Configurar credenciais federadas (substitua os valores)
az identity federated-credential create \
  --name github-actions-federation \
  --identity-name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:toolbox-tech/embracon:ref:refs/heads/feature/k8s-rbac" \
  --audience "api://AzureADTokenExchange"
```

Adicione credenciais federadas adicionais para outras branches ou workflows específicos:

```bash
# Para a branch main
az identity federated-credential create \
  --name github-actions-main \
  --identity-name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:toolbox-tech/embracon:ref:refs/heads/main" \
  --audience "api://AzureADTokenExchange"

# Para execução manual de workflow (workflow_dispatch)
az identity federated-credential create \
  --name github-actions-manual \
  --identity-name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:toolbox-tech/embracon:environment:Production" \
  --audience "api://AzureADTokenExchange"
```

## Configuração no GitHub

### 1. Adicionar secrets no GitHub

Adicione os seguintes secrets no seu repositório GitHub:

- `AZURE_CLIENT_ID`: O Client ID da identidade gerenciada criada
- `AZURE_TENANT_ID`: O Tenant ID da sua assinatura Azure
- `AZURE_SUBSCRIPTION_ID`: O ID da sua assinatura Azure

### 2. Atualizar workflow para usar OIDC

Atualize seus workflows para usar autenticação OIDC:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    # Opcional: definir um ambiente para usar a configuração OIDC baseada em ambiente
    environment: Production
    
    # Adicionar permissão para uso de OIDC
    permissions:
      id-token: write
      contents: read
    
    steps:
      - name: Login no Azure com OIDC
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Testando a Configuração

Para testar a configuração:

1. Execute manualmente o workflow através da interface do GitHub
2. Verifique os logs de execução para confirmar o sucesso da autenticação
3. Confirme que as ações que exigem autenticação no Azure são concluídas com sucesso

## Solução de Problemas

### Erros de Autenticação OIDC

- **Erro de credenciais federadas**: Verifique se o formato de "subject" está correto na configuração de credenciais federadas
- **Erro de permissão**: Confirme se a identidade gerenciada tem as permissões necessárias nos recursos
- **Erro de tenant**: Verifique se o tenant ID está correto

### Logs de Diagnóstico

```bash
# Verificar configuração de credenciais federadas
az identity federated-credential list --identity-name $IDENTITY_NAME --resource-group $RESOURCE_GROUP

# Verificar atribuições de função
az role assignment list --assignee $CLIENT_ID
```

### Ativar Logs Detalhados

Adicione o seguinte na etapa de login para obter logs mais detalhados:

```yaml
- name: Login no Azure com OIDC
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    enable-AzPSSession: false
    environment: 'AzureCloud'
    allow-no-subscriptions: false
```

---

## Recursos Adicionais

- [Documentação oficial do Azure sobre OIDC](https://docs.microsoft.com/pt-br/azure/active-directory/develop/v2-protocols-oidc)
- [GitHub Actions com OIDC](https://docs.github.com/pt/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Melhores práticas de segurança para GitHub Actions](https://docs.github.com/pt/actions/security-guides/security-hardening-for-github-actions)
