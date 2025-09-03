# Azure Container Registry - Configuração e Boas Práticas

Este documento contém instruções detalhadas para configuração do Azure Container Registry e recomendações de boas práticas de segurança.

## 📝 Índice

1. [Criação e Configuração do ACR](#criação-e-configuração-do-acr)
2. [Segurança do ACR](#segurança-do-acr)
3. [Integração com Azure Kubernetes Service (AKS)](#integração-com-azure-kubernetes-service-aks)
4. [Políticas de Retenção e Limpeza](#políticas-de-retenção-e-limpeza)
5. [Monitoramento e Alertas](#monitoramento-e-alertas)

## Criação e Configuração do ACR

### 1. Criando um novo Azure Container Registry

```powershell
# Definir variáveis
$resourceGroupName = "embracon-infra"
$acrName = "embraconacr"
$location = "brazilsouth"
$sku = "Premium"  # Premium é necessário para recursos avançados como geo-replicação e zonas de disponibilidade

# Criar o grupo de recursos (se ainda não existir)
az group create --name $resourceGroupName --location $location

# Criar o Azure Container Registry
az acr create --resource-group $resourceGroupName --name $acrName --sku $sku --admin-enabled false
```

### 2. Habilitando recursos avançados

```powershell
# Habilitar escaneamento de vulnerabilidades
az acr security enable-scan --name $acrName --resource-group $resourceGroupName --enable-scan

# Configurar retenção de imagens (manter apenas as últimas 10 versões de cada imagem)
az acr config retention update --name $acrName --resource-group $resourceGroupName --status enabled --days 0 --type UntaggedManifests --count 10
```

### 3. Configurando geo-replicação para alta disponibilidade

```powershell
# Adicionar replicação para outra região
az acr replication create --registry $acrName --resource-group $resourceGroupName --location eastus
```

## Segurança do ACR

### 1. Autenticação com Azure AD

```powershell
# Criar uma identidade gerenciada para aplicações
$identityName = "app-identity"
az identity create --name $identityName --resource-group $resourceGroupName

# Obter o ID da identidade
$identityPrincipalId = az identity show --name $identityName --resource-group $resourceGroupName --query principalId --output tsv

# Conceder acesso de AcrPull à identidade
$acrId = az acr show --name $acrName --resource-group $resourceGroupName --query id --output tsv
az role assignment create --assignee $identityPrincipalId --scope $acrId --role AcrPull
```

### 2. Habilitando Firewall e Regras de Rede

```powershell
# Configurar ACR para aceitar tráfego apenas de determinados IPs
az acr network-rule add --name $acrName --resource-group $resourceGroupName --ip-address 203.0.113.0/24

# Desabilitar acesso público direto
az acr update --name $acrName --resource-group $resourceGroupName --public-network-enabled false

# Habilitar endpoints privados
az network private-endpoint create \
    --name "acr-private-endpoint" \
    --resource-group $resourceGroupName \
    --vnet-name "vnet-principal" \
    --subnet "subnet-servicos" \
    --private-connection-resource-id $acrId \
    --group-id registry \
    --connection-name "acrConnection"
```

### 3. Bloqueio de Imagens Vulneráveis

```powershell
# Configurar política para bloquear imagens com vulnerabilidades críticas ou altas
az acr policy create --name $acrName --resource-group $resourceGroupName --type SecurityScan --status enabled --threshold High
```

## Integração com Azure Kubernetes Service (AKS)

### 1. Configurar AKS para usar o ACR

```powershell
$aksName = "embracon-aks"

# Conceder ao AKS acesso ao ACR
az aks update --name $aksName --resource-group $resourceGroupName --attach-acr $acrName

# Ou usando identidade atribuída pelo usuário
$aksIdentityId = az aks show --name $aksName --resource-group $resourceGroupName --query identityProfile.kubeletidentity.objectId -o tsv
az role assignment create --assignee $aksIdentityId --scope $acrId --role AcrPull
```

### 2. Configurando Pull Secrets (caso necessário)

```powershell
# Obter credenciais do ACR (se autenticação de admin estiver habilitada)
$acrUsername = az acr credential show --name $acrName --query username -o tsv
$acrPassword = az acr credential show --name $acrName --query passwords[0].value -o tsv

# Criar secret no Kubernetes
kubectl create secret docker-registry acr-auth \
    --docker-server="$acrName.azurecr.io" \
    --docker-username="$acrUsername" \
    --docker-password="$acrPassword" \
    --docker-email="admin@embracon.com.br"
```

## Políticas de Retenção e Limpeza

### 1. Configurando políticas de limpeza

```powershell
# Configurar retenção para remover imagens não utilizadas após 90 dias
az acr config retention update \
    --name $acrName \
    --resource-group $resourceGroupName \
    --status enabled \
    --days 90 \
    --type UntaggedManifests

# Criar tarefa para limpeza periódica
az acr task create \
    --name "acrPurgeTask" \
    --registry $acrName \
    --resource-group $resourceGroupName \
    --cmd "acr purge --filter 'mirrors/maven:.*' --ago 90d --untagged" \
    --schedule "0 1 * * Sun" \
    --context /dev/null
```

### 2. Implementando tagging semântico

Diretrizes para uso de tags:
- Use versionamento semântico: `major.minor.patch`
- Adicione data para builds: `v1.2.3-20231115`
- Marque imagens estáveis como: `stable`, `production`
- Nunca sobrescreva tags (sempre adicione novas)

```powershell
# Exemplo de aplicação de múltiplas tags
az acr import \
    --name $acrName \
    --source docker.io/library/node:18-alpine \
    --image mirrors/node:18-alpine \
    --image mirrors/node:18 \
    --image mirrors/node:stable
```

## Monitoramento e Alertas

### 1. Configurando métricas e logs

```powershell
# Habilitar diagnóstico de logs
$logAnalyticsId = az monitor log-analytics workspace show --resource-group $resourceGroupName --workspace-name "embracon-logs" --query id -o tsv

az monitor diagnostic-settings create \
    --name "acrDiagnostics" \
    --resource $acrId \
    --workspace $logAnalyticsId \
    --logs '[{"category": "ContainerRegistryRepositoryEvents", "enabled": true}, {"category": "ContainerRegistryLoginEvents", "enabled": true}]' \
    --metrics '[{"category": "AllMetrics", "enabled": true}]'
```

### 2. Configurando alertas

```powershell
# Criar alerta para falhas de autenticação
az monitor alert create \
    --name "ACRAuthFailure" \
    --resource-group $resourceGroupName \
    --scopes $acrId \
    --condition "count 'ContainerRegistryLoginEvents' where OperationName == 'Authenticate' and ResultType == 'Failure' > 5" \
    --description "Alerta para múltiplas falhas de autenticação no ACR" \
    --action-group "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/microsoft.insights/actionGroups/{actionGroupName}"
```

## Integração dos Scripts de Espelhamento

Para integrar os scripts de espelhamento com a configuração do ACR:

```powershell
# Definir permissões para o usuário/serviço que vai executar o script de espelhamento
$spId = az ad sp create-for-rbac --name "acr-mirror-service" --query appId -o tsv
az role assignment create --assignee $spId --scope $acrId --role Contributor

# Configurar ambiente para execução dos scripts
$env:AZURE_CLIENT_ID = $spId
$env:AZURE_TENANT_ID = "<tenant-id>"
$env:AZURE_CLIENT_SECRET = "<client-secret>"

# Executar script de espelhamento com autenticação de serviço
./mirror-dockerhub-to-acr.ps1 -ConfigFile ./docker-images.json -AcrName $acrName -AcrResourceGroup $resourceGroupName -SubscriptionId "<subscription-id>"
```

## Recursos Adicionais

- [Documentação oficial do Azure Container Registry](https://docs.microsoft.com/pt-br/azure/container-registry/)
- [Melhores práticas para ACR](https://docs.microsoft.com/pt-br/azure/container-registry/container-registry-best-practices)
- [Integração de ACR com AKS](https://docs.microsoft.com/pt-br/azure/aks/cluster-container-registry-integration)
- [Azure Policy para ACR](https://docs.microsoft.com/pt-br/azure/governance/policy/samples/built-in-policies#container-registries)
