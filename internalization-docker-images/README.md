<p align="center">
  <img src="../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# 🐳 Internalização de Imagens Docker

## 🎯 Sobre o Módulo

Este módulo contém instruções detalhadas para configuração do Azure Container Registry e recomendações para internalização de imagens Docker do Docker Hub. Seguindo estas diretrizes, você poderá:

- 🛡️ Reduzir dependências externas do Docker Hub
- 🚫 Evitar problemas com limites de rate limiting
- 🔒 Melhorar a segurança com escaneamento## 🚀 Otimização e Economia de Recursos

A implementação de verificação por digest nos workflows de espelhamento de imagens oferece diversos benefícios:

### 1. Sincronização completa com arquivo JSON

O processo agora gerencia o ciclo de vida completo das imagens no ACR:
- **Importação** de imagens definidas no arquivo JSON
- **Verificação de digest** para evitar transferências desnecessárias
- **Remoção automática** de imagens que não estão mais no JSON

Isso garante que apenas as imagens oficialmente aprovadas e documentadas no JSON permaneçam no registro, mantendo-o limpo e atualizado.

### 2. Economia de largura de banda

Ao verificar tanto as tags quanto os digests das imagens, os workflows evitam o download desnecessário de imagens que não mudaram. Isso pode representar economia significativa de largura de banda, especialmente para imagens grandes como as baseadas em JDK.

### 3. Redução de custos

Menos transferência de dados entre registros significa:
- Menor custo de rede (entrada/saída)
- Menor utilização de recursos computacionais
- Menor tempo de execução dos workflows
- Menos armazenamento usado no ACR (remoção automática de imagens obsoletas)idades
- ⚡ Acelerar o tempo de deploy dos seus containers

## 📑 Índice

- [🎯 Sobre o Módulo](#-sobre-o-módulo)
- [🚀 Proposta](#proposta)
- [🚀 Início Rápido](#-início-rápido)
- [🛠️ Criação e Configuração do ACR](#-criação-e-config## 📝 Histórico de Alterações

| Data | Versão | Descrição | Autor |
|------|--------|-----------|-------|
| 04/09/2025 | 1.0.0 | Criação do documento com instruções para ACR | Equipe DevOps |
| 04/09/2025 | 1.0.1 | Correção de sintaxe em scripts PowerShell | Equipe DevOps |
| 04/09/2025 | 1.1.0 | Adição de seção de importação em massa de imagens | Equipe DevOps |
| 05/09/2025 | 1.2.0 | Implementação de verificação por digest com Docker Manifest | Equipe DevOps |
| 05/09/2025 | 1.3.0 | Simplificação do processo: removida implementação para imagens privadas | Equipe DevOps |
| 05/09/2025 | 1.4.0 | Simplificação: uso exclusivo de `az acr import` para internalização | Equipe DevOps |
| 05/09/2025 | 1.5.0 | Implementação de remoção automática de imagens ausentes do JSON | Equipe DevOps |
| 05/09/2025 | 1.3.0 | Simplificação do processo: removida implementação para imagens privadas | Equipe DevOps |
| 05/09/2025 | 1.4.0 | Simplificação: uso exclusivo de `az acr import` para internalização | Equipe DevOps |o-acr)
  - [Criando um novo Azure Container Registry](#1-criando-um-novo-azure-container-registry)
 ## 🚀 Otimização e Economia de Recursos

A implementação de verificação por digest nos workflows de espelhamento de imagens oferece diversos benefícios:

### 1. Importação Otimizada com az acr import

A utilização do comando `az acr import` representa uma evolução significativa no processo de importação:

```bash
# Importação direta do Docker Hub para o ACR
az acr import --name myacr --source docker.io/library/maven:3.8.1-jdk-11-slim --image maven:3.8.1-jdk-11-slim
```

Benefícios desta abordagem:
- **Transferência direta**: A imagem é transferida diretamente do Docker Hub para o ACR
- **Autenticação simplificada**: Gerencia as credenciais para ambos os registros
- **Verificação integrada**: Verifica automaticamente se é necessário atualizar
- **Menor pressão nos runners**: Os runners do GitHub Actions não precisam baixar ou armazenar as imagens

### 2. Economia de largura de banda

Ao verificar tanto as tags quanto os digests das imagens através de manifests, os workflows evitam o download desnecessário de imagens que não mudaram. Isso pode representar economia significativa de largura de banda, especialmente para imagens grandes como as baseadas em JDK.

### 3. Redução de custos

Menos transferência de dados entre registros significa:
- Menor custo de rede (entrada/saída)
- Menor utilização de recursos computacionais
- Menor tempo de execução dos workflowso recursos avançados](#2-habilitando-recursos-avançados)
  - [Configurando geo-replicação para alta disponibilidade](#3-configurando-geo-replicação-para-alta-disponibilidade)
- [🔒 Segurança do ACR](#-segurança-do-acr)
  - [Autenticação com Azure AD](#1-autenticação-com-azure-ad)
- [📥 Importando Imagens do Docker Hub](#-importando-imagens-do-docker-hub)
  - [Importação básica de imagens](#1-importação-básica-de-imagens)
  - [Importação com namespace personalizado](#2-importação-com-namespace-personalizado)
  - [Importação com autenticação para registros privados](#3-importação-com-autenticação-para-registros-privados)
  - [Importação em massa de várias tags de uma imagem](#4-importação-em-massa-de-várias-tags-de-uma-imagem)
  - [Boas práticas para importação](#5-boas-práticas-para-importação)
  - [Automação com Azure Logic Apps](#6-automação-com-azure-logic-apps)
- [🔄 Workflow GitHub Actions para Espelhamento](#-workflow-github-actions-para-espelhamento)
  - [Workflow para Imagens Públicas](#workflow-para-imagens-públicas)
- [🔄 Integração com Azure Kubernetes Service (AKS)](#-integração-com-azure-kubernetes-service-aks)
- [🧹 Políticas de Retenção e Limpeza](#-políticas-de-retenção-e-limpeza)
- [📊 Monitoramento e Alertas](#-monitoramento-e-alertas)

## Proposta

```mermaid
flowchart TB
  %% Orientação: Vertical (Top to Bottom)
  classDef dashed stroke-dasharray: 5 5

  subgraph CI[CI • GitHub Actions]
    EXT["Fonte Externa (Docker Hub / Temurin OpenJDK)" ]
    CACHE["(Opcional) Cache/Proxy de Registry (ACR Tasks/Cache)"]:::dashed
    GHA["Workflow de Internalização"]
    PULL["Step: Pull imagem base (OpenJDK) + pin por digest (sha256)"]
    CUST["Step: Customização (Dockerfile: CA internos, timezone, hardening)"]
    BUILD["Step: Build & Tag (ex.: openjdk:17-internal → 17.0.12-internal-YYYYMMDD)"]
  end

  subgraph SEC[Segurança]
    TRIVY["Trivy Scan (CVE/Secrets/Misconfig) + SBOM (spdx/json)"]
    GATE["Gate: falha se severidade ≥ High/Critical"]
    SBOM["Artefatos: publicar SBOM/relatórios (Actions artefacts)"]
  end

  subgraph REG[Registry • Azure Container Registry]
    PUSH["Push para ACR (OIDC federado GitHub → Azure) + retag"]
    ACR_REPO["contoso.azurecr.io/openjdk"]
    TAGS["Promoção por tags: :dev → :staging → :prod (retag/alias imutável)"]
    POLICY["Políticas: retenção/TTL, bloquear latest, imutável por digest"]
  end

  subgraph CD[CD & Promoção]
    CDPIPE["CD: GitHub Actions (ou GitOps) por ambiente (dev/staging/prod)"]
  end

  subgraph RT[Runtime • AKS & OKE]
    subgraph AKS[AKS]
      AKS1["Pull do ACR (Workload Identity / ACR Pull)"]
      AKS2["Admission Policies (Gatekeeper/Kyverno): imagem/tag/CVE gate"]
      AKS3["Deploy (Helm/Manifests): usa :dev/:staging/:prod (por digest)"]
    end
    subgraph OKE[OKE]
      OKE1["Pull do ACR (Secret dockerconfigjson / Federation)"]
      OKE2["Admission Policies (OPA/Kyverno) + enforce digest-only (prod)"]
      OKE3["Deploy (Helm/Manifests): mesmas versões promovidas do ACR"]
    end
  end

  %% Fluxo CI
  EXT --> PULL
  CACHE -. opcional .-> PULL
  GHA --> PULL --> CUST --> BUILD

  %% Segurança
  BUILD --> TRIVY --> GATE --> SBOM

  %% Push/Registry
  SBOM --> PUSH --> ACR_REPO --> TAGS --> POLICY

  %% CD
  POLICY --> CDPIPE

  %% Runtime
  CDPIPE --> AKS1 --> AKS2 --> AKS3
  CDPIPE --> OKE1 --> OKE2 --> OKE3
```

## 🚀 Início Rápido

Para começar rapidamente com a internalização de imagens Docker:

1. Crie um Azure Container Registry Premium: `az acr create --resource-group embracon-infra --name embraconacr --sku Premium`
2. Configure políticas de retenção: `az acr config retention update --registry embraconacr --status enabled --days 7 --type UntaggedManifests`
3. Importe imagens do Docker Hub: `az acr import --name embraconacr --source docker.io/library/nginx:latest --image nginx:latest`

## 🛠️ Criação e Configuração do ACR

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
# Configurar retenção de imagens (manter por apenas 7 dias imagens não utilizadas)
az acr config retention update --registry $acrName --resource-group $resourceGroupName --status enabled --days 7 --type UntaggedManifests
```

### 3. Configurando geo-replicação para alta disponibilidade

```powershell
# Adicionar replicação para outra região
az acr replication create --registry $acrName --resource-group $resourceGroupName --location eastus
```

## 🔒 Segurança do ACR

### 1. Autenticação com Azure AD

```powershell
# Criar uma identidade gerenciada para aplicações
$identityName = "app-identity"
az identity create --name $identityName --resource-group $resourceGroupName

# Obter o ID da identidade
$identityPrincipalId = az identity show --name $identityName --resource-group $resourceGroupName --query principalId --output tsv

# Criar um grupo do Azure AD para usuários do ACR
$groupName = "ACR-Users"
$groupDescription = "Grupo para usuários com acesso total ao Azure Container Registry"

# Criar o grupo
az ad group create --display-name $groupName --mail-nickname "acr-users" --description $groupDescription

# Obter o ID do grupo criado
$groupId = az ad group show --group $groupName --query id --output tsv

# Adicionar usuário criado ao grupo
az ad group member add --group $groupName --member-id $identityPrincipalId

# Obter o ID do ACR
$acrId = az acr show --name $acrName --resource-group $resourceGroupName --query id --output tsv

# Alternativamente, conceder permissões específicas do ACR
az role assignment create --assignee $groupId --scope $acrId --role "Container Registry Data Importer and Data Reader"
az role assignment create --assignee $groupId --scope $acrId --role AcrPush
az role assignment create --assignee $groupId --scope $acrId --role AcrPull
az role assignment create --assignee $groupId --scope $acrId --role AcrDelete
az role assignment create --assignee $groupId --scope $acrId --role AcrRead

# Verificar as permissões atribuídas
az role assignment list --scope $acrId --output table
```

```powershell
# Para adicionar mais usuários ao grupo posteriormente
$novoUsuario = "novo.usuario@embracon.com.br"
az ad group member add --group $groupName --member-id $(az ad user show --id $novoUsuario --query id --output tsv)

# Listar membros do grupo
az ad group member list --group $groupName --query "[].{Name:displayName, Email:userPrincipalName}" --output table
# Conceder acesso de AcrPull à identidade
$acrId = az acr show --name $acrName --resource-group $resourceGroupName --query id --output tsv
az role assignment create --assignee $identityPrincipalId --scope $acrId --role AcrPull

# Conceder acesso de push
az role assignment create --assignee $identityPrincipalId --scope $acrId --role AcrPush
```

## 📥 Importando Imagens do Docker Hub

A Azure oferece uma maneira simplificada de importar imagens diretamente do Docker Hub (ou de outros registros) para o ACR sem precisar baixar e fazer upload manualmente.

### 1. Importação básica de imagens

```powershell
# Importar uma imagem do Docker Hub para o ACR
az acr import `
  --name $acrName `
  --source docker.io/library/nginx:latest `
  --image nginx:latest
```

### 2. Importação com namespace personalizado

```powershell
# Importar com namespace personalizado
az acr import `
  --name $acrName `
  --source docker.io/library/redis:6-alpine `
  --image cache/redis:6-alpine
```

### 3. Importação com autenticação (quando necessário)

```powershell
# Importar com autenticação (quando necessário)
az acr import `
  --name $acrName `
  --source docker.io/library/image:tag `
  --image mirrors/image:tag `
  --username <username> `
  --password <password>
```

### 4. Importação em massa de várias tags de uma imagem

#### Via CLI

```powershell
# Definir as tags a serem importadas
$imageTags = @("18-alpine", "18.12-alpine", "18.13-alpine", "20-alpine")
$sourceRepo = "docker.io/library/node"
$targetRepo = "devops/node"

# Importar cada tag
foreach ($tag in $imageTags) {
    Write-Host "Importando ${sourceRepo}:${tag} para ${targetRepo}:${tag}..."
    az acr import `
      --name $acrName `
      --source "${sourceRepo}:${tag}" `
      --image "${targetRepo}:${tag}"
}
```
#### JSON
```powershell
# Definir as tags a serem importadas a partir do arquivo JSON
$jsonFile = "internalization-docker-images/docker-public-images.json"
$imagesData = Get-Content $jsonFile | ConvertFrom-Json

# Importar cada imagem definida no arquivo JSON
foreach ($imageInfo in $imagesData.images) {
  $sourceRepo = "docker.io/library/$($imageInfo.repository)"
  $targetRepo = $imageInfo.targetRepository
  $tag = $imageInfo.tag
  
  Write-Host "Importando ${sourceRepo}:${tag} para ${targetRepo}:${tag}..."
  az acr import `
    --name $acrName `
    --source "${sourceRepo}:${tag}" `
    --image "${targetRepo}:${tag}"
}
```


### 5. Boas práticas para importação

1. **Use prefixos organizacionais**: Organize suas imagens com prefixos como `prod/`, `dev/`, `mirrors/`
2. **Importe versões específicas**: Evite usar a tag `latest` e prefira versões específicas
3. **Verifique os digests das imagens**: Use `docker manifest inspect` para verificar digests de forma eficiente sem downloads completos
4. **Documente as imagens importadas**: Mantenha um registro de quais imagens foram importadas e quando
5. **Configure importação automática**: Use tarefas agendadas para manter imagens atualizadas
6. **Economize largura de banda**: Implemente verificação por tag e digest para evitar downloads desnecessários

## 🔄 Workflow GitHub Actions para Espelhamento

Implementamos um workflow GitHub Actions para espelhamento de imagens Docker públicas para o ACR usando autenticação OIDC com o Azure.

O workflow inclui as seguintes funcionalidades:

- ✅ Autenticação no Docker Hub para evitar problemas de rate limiting
- ✅ Autenticação federada com Azure (OIDC)
- ✅ Importação eficiente de imagens usando `az acr import`
- ✅ Verificação por digest para garantir a integridade do conteúdo das imagens
- ✅ Tratamento de erros e opção para forçar atualização de imagens

#### Atualização Eficiente de Imagens

O uso do comando `az acr import` oferece uma forma eficiente de internalizar imagens do Docker Hub para o ACR:

1. **Transferência direta**: As imagens são transferidas diretamente do Docker Hub para o ACR sem precisar baixá-las para o runner do GitHub Actions
2. **Verificação implícita**: O ACR automaticamente verifica se a imagem já existe e se o conteúdo mudou
3. **Parâmetro force**: O uso da flag `--force` permite atualizar imagens mesmo quando a tag já existe

Esta abordagem traz múltiplos benefícios:
- **Simplicidade**: Código mais conciso e fácil de manter
- **Eficiência de recursos**: Menor consumo de recursos no runner do GitHub Actions
- **Autenticação integrada**: Gerencia automaticamente as autenticações entre registros
- **Economia significativa**: Redução no consumo de largura de banda e custo de transferência
- **Execução mais rápida**: Workflows completam em menos tempo devido ao processo otimizado

### Workflow para Imagens Públicas

Este workflow espelha imagens públicas do Docker Hub definidas no arquivo `docker-public-images.json`:

```yaml
name: Mirror Public Docker Images to ACR

on:
  # Executa diariamente à meia-noite
  schedule:
    - cron: '0 0 * * *'
  # Permite execução manual pelo GitHub UI
  workflow_dispatch:
  # Executa quando o arquivo docker-public-images.json é modificado
  push:
    branches:
      - main
    paths:
      - 'internalization-docker-images/docker-public-images.json'

jobs:
  mirror-public-images:
    name: Mirror Public Docker Images to ACR
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Azure Login via OIDC
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Log in to Azure Container Registry
        run: az acr login -n ${{ vars.ACR_NAME }}
      
      - name: Mirror Public Docker Images
        run: |
          ACR_NAME="${{ vars.ACR_NAME }}"
          RESOURCE_GROUP="${{ vars.RESOURCE_GROUP }}"
          PREFIX="embracon-"
          
          echo "Using ACR: $ACR_NAME in resource group: $RESOURCE_GROUP"
          
          # Ler imagens do arquivo JSON
          IMAGES=$(cat "internalization-docker-images/docker-public-images.json" | jq -c '.images')
          
          echo "$IMAGES" | jq -c '.[]' | while read -r image; do
            REPO=$(echo "$image" | jq -r '.repository')
            TAG=$(echo "$image" | jq -r '.tag')
            TARGET_REPO=$(echo "$image" | jq -r '.targetRepository')
            
            echo "Importing $REPO:$TAG to $PREFIX$TARGET_REPO:$TAG"
            
            if ! az acr import \
              --name "$ACR_NAME" \
              --resource-group "$RESOURCE_GROUP" \
              --source "docker.io/library/$REPO:$TAG" \
              --image "$PREFIX$TARGET_REPO:$TAG" \
              --username ${{ vars.DOCKERHUB_USERNAME }} \
              --password ${{ secrets.DOCKERHUB_TOKEN }} \
              --force; then
              echo "Error: Failed to import $REPO:$TAG to $PREFIX$TARGET_REPO:$TAG"
            fi
          done
```

Para configurar este workflow, consulte o documento [WORKFLOW-SETUP.md](WORKFLOW-SETUP.md) com instruções detalhadas.

## 🔄 Integração com Azure Kubernetes Service (AKS)

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

## 🧹 Políticas de Retenção e Limpeza

### 1. Configurando políticas de limpeza

```powershell
# Configurar retenção para remover imagens não utilizadas após 90 dias
az acr config retention update \
    --registry $acrName \
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

## � Otimização e Economia de Recursos

A implementação de verificação por digest nos workflows de espelhamento de imagens oferece diversos benefícios:

### 1. Economia de largura de banda

Ao verificar tanto as tags quanto os digests das imagens, os workflows evitam o download desnecessário de imagens que não mudaram. Isso pode representar economia significativa de largura de banda, especialmente para imagens grandes como as baseadas em JDK.

### 2. Redução de custos

Menos transferência de dados entre registros significa:
- Menor custo de rede (entrada/saída)
- Menor utilização de recursos computacionais
- Menor tempo de execução dos workflows

### 3. Métricas de economia

Para avaliar os benefícios da verificação por digest, você pode acompanhar:

```powershell
# Script para calcular economia com base nos logs
$startDate = (Get-Date).AddDays(-30)
$endDate = Get-Date
$logs = az monitor log-analytics query --workspace $workspaceId --query-string "ContainerRegistryRepositoryEvents | where TimeGenerated between (datetime($startDate) .. datetime($endDate)) | where Message contains 'mesmo digest' | summarize EconomiaBytes=sum(tolong(SizeInBytes)) by bin(TimeGenerated, 1d)" -o tsv

# Converter bytes para MB/GB para melhor visualização
$totalEconomia = $logs | Measure-Object -Property EconomiaBytes -Sum
Write-Output "Economia total no último mês: $($totalEconomia.Sum / 1GB) GB"
```

## �📊 Monitoramento e Alertas

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

## 📚 Recursos Adicionais

- [Documentação oficial do Azure Container Registry](https://docs.microsoft.com/pt-br/azure/container-registry/)
- [Melhores práticas para ACR](https://docs.microsoft.com/pt-br/azure/container-registry/container-registry-best-practices)
- [Integração de ACR com AKS](https://docs.microsoft.com/pt-br/azure/aks/cluster-container-registry-integration)
- [Azure Policy para ACR](https://docs.microsoft.com/pt-br/azure/governance/policy/samples/built-in-policies#container-registries)
- [Visão geral das permissões e atribuições de função do Registro de Contêiner do Azure Entra](https://learn.microsoft.com/pt-br/azure/container-registry/container-registry-rbac-built-in-roles-overview?tabs=registries-configured-with-rbac-registry-permissions)
- [Limites de rate limiting do Docker Hub](https://docs.docker.com/docker-hub/download-rate-limit/)
- [Trivy - Scanner de Vulnerabilidades para Containers](https://github.com/aquasecurity/trivy)

---

## � Solução de Problemas com Verificação de Digest

Ao trabalhar com a verificação de digest das imagens Docker, você pode encontrar alguns desafios:

### 1. Problemas com Docker Manifest

Se o comando `docker manifest inspect` falhar, verifique os seguintes pontos:

```bash
# Habilitando recursos experimentais (obrigatório para docker manifest)
export DOCKER_CLI_EXPERIMENTAL=enabled

# Verificando se o manifesto está disponível
docker manifest inspect docker.io/library/maven:3.8.1-jdk-11-slim

# Extraindo digest sem usar jq (mais compatível)
docker manifest inspect docker.io/library/maven:3.8.1-jdk-11-slim | grep digest | head -n 1 | awk '{print $2}' | tr -d ',"'

# Se falhar, tentar métodos alternativos
docker pull docker.io/library/maven:3.8.1-jdk-11-slim
docker inspect docker.io/library/maven:3.8.1-jdk-11-slim | grep RepoDigests -A 1 | tail -n 1 | awk -F '@' '{print $2}' | tr -d '",'
```

### 2. Diferenças de Digest entre Registros

Em alguns casos, o digest pode diferir entre o registro de origem e o ACR devido a:
- Normalização de layers nas imagens
- Diferenças nos formatos de manifesto
- Conversão automática entre formatos (v1, v2, OCI)

Nestes casos, considere verificar apenas tags específicas ou implementar lógica personalizada.

## �📝 Histórico de Alterações

| Data | Versão | Descrição | Autor |
|------|--------|-----------|-------|
| 04/09/2025 | 1.0.0 | Criação do documento com instruções para ACR | Equipe DevOps |
| 04/09/2025 | 1.0.1 | Correção de sintaxe em scripts PowerShell | Equipe DevOps |
| 04/09/2025 | 1.1.0 | Adição de seção de importação em massa de imagens | Equipe DevOps |
| 05/09/2025 | 1.2.0 | Implementação de verificação por digest com Docker Manifest | Equipe DevOps |

## 📞 Suporte e Contribuição

### **Para Dúvidas e Suporte:**
- 📧 Entre em contato com a equipe de DevOps
- 📖 Consulte a documentação específica de cada módulo
- 🔍 Verifique os guias de troubleshooting

### **Para Contribuições:**
- 🍴 Fork o repositório
- 🌿 Crie uma branch para sua feature
- 📝 Siga as boas práticas de commit
- 📤 Abra um Pull Request

## ⚠️ Aviso Legal

As informações contidas neste documento são apenas para fins educacionais e de orientação. Cada implementação deve ser avaliada de acordo com os requisitos específicos de segurança e conformidade da organização.

---

<p align="center">
  <strong>🚀 Embracon - DevOps e Infraestrutura 🛡️</strong><br>
    <em>🏢 Toolbox Tech - Soluções Padronizadas</em>
</p>
