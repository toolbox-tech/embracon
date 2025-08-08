<p align="center">
  <img src="anexos/img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# 🗝️ Guia para acessar um segredo no Azure Key Vault (AKV) a partir do Azure Kubernetes Service (AKS) - Linux

Este guia apresenta um passo a passo para acessar segredos do Azure Key Vault (AKV) a partir do Azure Kubernetes Service (AKS) de forma segura, utilizando a Federação de Identidade de Carga de Trabalho (Workload Identity Federation) via OIDC, External Secrets Operator e RBAC do Azure.

## 👀 Visão Geral

- 🔒 **Elimina o "Secret Zero"**: Não é necessário armazenar secrets fixos no cluster.
- 🛡️ **Segurança aprimorada**: O acesso é feito por tokens temporários emitidos via OIDC.
- 🤖 **Automação**: Permissões dinâmicas para workloads, sem rotacionar secrets manualmente.
- 🗂️ **Gerenciamento centralizado**: RBAC do Azure AD controla o acesso aos segredos.

---

## 1. 🧩 Conceitos-Chave

- 🕵️‍♂️ **Secret Zero**: Segredo inicial que, se exposto, compromete todo o acesso. Eliminado com OIDC.
- 🔗 **OIDC (OpenID Connect)**: Protocolo de autenticação que permite ao AKS emitir tokens para workloads.
- 👷 **Workload Identity Federation**: Permite que pods do AKS assumam identidades do Azure AD sem secrets.
- 🔄 **External Secrets Operator**: Sincroniza segredos do AKV para o Kubernetes.
- 🛡️ **RBAC do Azure**: Gerencia quem pode acessar quais segredos no AKV.

---

## 2. 📝 Pré-requisitos

- 💻 Azure CLI configurado (`az login`)
- 🛠️ Permissões para criar recursos no Azure (AKS, Key Vault, Managed Identity, Grupos)
- 🧢 Helm instalado para deploy do External Secrets Operator

---

## 3. 🏃 Fluxo Resumido

1. 👥 Crie um grupo no Azure AD para controle de acesso.
2. 🆔 Crie uma Managed Identity para workloads do AKS.
3. ➕ Adicione a Managed Identity ao grupo criado.
4. 🔐 Crie o Key Vault com RBAC habilitado.
5. ☁️ Crie ou atualize o cluster AKS com OIDC habilitado.
6. 🔄 Configure a federação de identidade entre o AKS e a Managed Identity.
7. 📦 Instale o External Secrets Operator no cluster.
8. 🧑‍💻 Crie a ServiceAccount no Kubernetes com as anotações necessárias.
9. 🏪 Crie o SecretStore apontando para o Key Vault.
10. 🛂 Conceda permissões de acesso ao grupo no Key Vault.
11. 🔁 Crie o recurso ExternalSecret para sincronizar segredos do AKV para o Kubernetes.

---

## 4. 🛠️ Passo a Passo

### 4.1. 🔑 Faça login e defina a subscription

Antes de iniciar, faça login no Azure CLI e defina a subscription correta:

```bash
az login
az account set --subscription "<SUA_SUBSCRIPTION_ID>"
```

Substitua `<SUA_SUBSCRIPTION_ID>` pelo ID da subscription desejada.

### 4.2. 🏷️ Defina Variáveis

```bash
export SEU_GROUP_NAME="akv-access-group"
export SEU_IDENTITY_MANAGED_NAME="test-aks-akv"
export SEU_RESOURCE_GROUP="Embracon-Test"
export SEU_KEYVAULT_NAME="akv-test-embracon"
export SUA_LOCALIZACAO="brazilsouth"
export SEU_AKS_NAME="aks-test"
export SERVICE_ACCOUNT_NAME="workload-identity-sa"
export NAMESPACE="default"
export TENANT_ID="$(az account show --query tenantId -o tsv)"
export SECRET_NAME="secretx"
```

### 4.3. 🏗️ Crie os Recursos no Azure

```bash
# Resource Group
az group create --name "$SEU_RESOURCE_GROUP" --location "$SUA_LOCALIZACAO"

# Grupo de acesso
az ad group create --display-name "$SEU_GROUP_NAME" --mail-nickname "$SEU_GROUP_NAME"

# Managed Identity
az identity create --name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --location "$SUA_LOCALIZACAO"

# Obtenha o Principal ID e Client ID da Managed Identity
export IDENTITY_PRINCIPAL_ID=$(az identity show --name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query principalId -o tsv)
export CLIENT_ID=$(az identity show --name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query clientId -o tsv)

# Adicione a Managed Identity ao grupo
az ad group member add --group "$SEU_GROUP_NAME" --member-id "$IDENTITY_PRINCIPAL_ID"

# Crie um Key Vault com RBAC
az keyvault create --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP" --location "$SUA_LOCALIZACAO" --enable-rbac-authorization true

# Após criar o KeyVault, você deve dar permissões aos usuários para poderem usá-lo

# Conceda permissão de "Administrador do Cofre de Chaves" ao usuário no Key Vault, este comando dará a permissão ao usuário logado para administrar o Key Vault recém-criado.
az role assignment create --assignee "$(az ad signed-in-user show --query id -o tsv)" --role "Key Vault Administrator" --scope $(az keyvault show --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query id -o tsv)

# Obtenha a URL do Vault
export KEY_VAULT_URL=$(az keyvault show --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query properties.vaultUri -o tsv)
```

### 4.4. ☁️ Crie ou Atualize o AKS com OIDC

**Novo cluster:**
```bash
az aks create --name "$SEU_AKS_NAME" --resource-group "$SEU_RESOURCE_GROUP" --location "$SUA_LOCALIZACAO" --enable-oidc-issuer --enable-managed-identity --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 3 --tier free --generate-ssh-keys
```

**Cluster existente:**
```bash
az aks update --name "$SEU_AKS_NAME" --resource-group "$SEU_RESOURCE_GROUP" --enable-oidc-issuer
```

Descubra o issuer URL do OIDC:
```bash
export AKS_OIDC_ISSUER=$(az aks show --name "$SEU_AKS_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query "oidcIssuerProfile.issuerUrl" -o tsv)
```

### 4.5. 🔄 Configure a Federação de Identidade

```bash
# Crie o subject
export SUBJECT="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}"

az identity federated-credential create --name "kubernetes-federated-credential" --identity-name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --issuer "$AKS_OIDC_ISSUER" --subject "$SUBJECT"
```

### 4.6 🔗 Conecte-se ao cluster criado

```bash
az aks get-credentials --name "$SEU_AKS_NAME" --resource-group "$SEU_RESOURCE_GROUP"
```

### 4.7.1 📦 Adicione o Repo do External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
```

### 4.7.2 📦 Instale o External Secrets Operator

```bash
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
```

> ℹ️ **Nota:**  
> É necessário ter o [Helm](https://helm.sh/docs/intro/install/) instalado.

### 4.8. 🧑‍💻 Crie a ServiceAccount no Kubernetes

Crie um arquivo `service-account.yaml` com as anotações necessárias (client-id, tenant-id).
(substitua pelos valores das variáveis que você obteve anteriormente):

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workload-identity-sa
  annotations:
    azure.workload.identity/client-id: "<CLIENT_ID>"
    azure.workload.identity/tenant-id: "<TENANT_ID>"
```

Para substituir automaticamente os valores das variáveis no arquivo:

```bash
cat <<EOF > service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workload-identity-sa
  annotations:
    azure.workload.identity/client-id: "$CLIENT_ID"
    azure.workload.identity/tenant-id: "$TENANT_ID"
EOF
```

Aplique o recurso:

```bash
kubectl apply -f service-account.yaml
```

### 4.9. 🏪 Crie o Secret Store

Crie um arquivo `secret-store.yaml` com o seguinte conteúdo:

```bash
cat <<EOF > secret-store.yaml
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: akv-secret-manager-store
  namespace: $NAMESPACE
spec:
  provider:
    azurekv:
      authType: WorkloadIdentity
      vaultUrl: "$KEY_VAULT_URL"
      serviceAccountRef:
        name: workload-identity-sa
EOF
```

Aplique o recurso:

```bash
kubectl apply -f secret-store.yaml
```

### 4.10. 🛂 Conceda Permissões no Key Vault

Conceda permissão de "Usuário de Segredos do Cofre de Chaves" ao grupo no Key Vault via CLI, assim ele poderá ver todos os secrets:

```bash
az role assignment create --assignee-object-id $(az ad group show --group "$SEU_GROUP_NAME" --query id -o tsv) --assignee-principal-type Group --role "Key Vault Secrets User" --scope $(az keyvault show --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query id -o tsv)
```

#### 🗝️ Crie o secret

```bash
az keyvault secret set --vault-name "$SEU_KEYVAULT_NAME" --name "$SECRET_NAME" --value "TESTE"
```

> ℹ️ **Nota:**  
> A criação do segredo se faz necessária somente para fins de exemplificação.

### 4.11. 🔁 Crie o External Secret 

Crie um arquivo `external-secret.yaml` com o seguinte conteúdo:

```bash
cat <<EOF > external-secret.yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: akv-external-secret-manager-store
  namespace: $NAMESPACE
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: akv-secret-manager-store
    kind: SecretStore
  target:
    name: my-app-secret-k8s-akv
    creationPolicy: Owner
  data:
    - secretKey: my-akv-secret-key
      remoteRef:
        key: $SECRET_NAME
EOF
```
> **Nota:**  
> - Substitua `nome-do-segredo-no-akv` pelo nome do segredo existente no Key Vault que deseja sincronizar.
> - O campo `secretKey` define o nome da chave no Secret do Kubernetes.
> - O campo `refreshInterval` define o intervalo de tempo para que o segredo seja atualizado a partir do SecretStore.
> - **# RefreshInterval é o intervalo de tempo antes dos valores serem lidos novamente do provedor SecretStore**
> - **# Unidades válidas: "ns", "us" (ou "µs"), "ms", "s", "m", "h" (conforme time.ParseDuration)**
> - **# Pode ser definido como zero para buscar e criar o segredo apenas uma vez**
> Para mais detalhes acesse [Extenal Secret](https://external-secrets.io/v0.4.4/api-externalsecret)

Aplique o recurso:

```bash
kubectl apply -f external-secret.yaml
```

### 4.12 👁️ Visualizando o Secrets

Para visualizar o Secret criado no Kubernetes:

```bash
kubectl get secret my-app-secret-k8s-akv -n $NAMESPACE
```

Para exibir o conteúdo do Secret (decodificando o valor):

```bash
kubectl get secret my-app-secret-k8s-akv -n $NAMESPACE -o jsonpath="{.data.my-akv-secret-key}" | base64 --decode
```

> **Nota:**  
> - O nome `my-app-secret-k8s-akv` corresponde ao campo `.spec.target.name` definido no recurso `ExternalSecret`.
> - O campo `my-akv-secret-key` corresponde ao campo `.spec.data.secretKey` do `ExternalSecret`.

---

## 5. 🧹 Limpeza dos Recursos (Cleanup)

Para remover todos os recursos criados durante este tutorial, execute os comandos abaixo na ordem apresentada:

### 5.1. 🧽 Remover recursos do Kubernetes

```bash
# Remover o ExternalSecret
kubectl delete externalsecret akv-external-secret-manager-store -n $NAMESPACE

# Remover o SecretStore
kubectl delete secretstore akv-secret-manager-store -n $NAMESPACE

# Remover o Secret criado (se existir)
kubectl delete secret my-app-secret-k8s-akv -n $NAMESPACE

# Remover o ServiceAccount
kubectl delete serviceaccount workload-identity-sa -n $NAMESPACE

# Desinstalar o External Secrets Operator
helm uninstall external-secrets -n external-secrets

# Remover o namespace do External Secrets Operator
kubectl delete namespace external-secrets
```

### 5.2. 🗑️ Remover Federated Identity Credential

```bash
# Remover o federated credential
az identity federated-credential delete --name "kubernetes-federated-credential" --identity-name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --yes
```

### 5.3. 🗑️ Remover recursos do Azure

```bash
# Remover role assignments (se foram criados)
az role assignment delete --assignee $(az ad group show --group "$SEU_GROUP_NAME" --query id -o tsv) --role "Key Vault Secrets User" --scope $(az keyvault show --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query id -o tsv)

# Remover o segredo do Key Vault (se foi criado)
az keyvault secret delete --vault-name "$SEU_KEYVAULT_NAME" --name "$SECRET_NAME"

# Purgar o segredo (remoção permanente)
az keyvault secret purge --vault-name "$SEU_KEYVAULT_NAME" --name "$SECRET_NAME"

# Remover a Managed Identity do grupo
az ad group member remove --group "$SEU_GROUP_NAME" --member-id "$IDENTITY_PRINCIPAL_ID"

# Deletar o cluster AKS (CUIDADO - isso remove todo o cluster!)
az aks delete --name "$SEU_AKS_NAME" --resource-group "$SEU_RESOURCE_GROUP" --yes --no-wait

# Deletar o Key Vault (CUIDADO - isso remove o cofre e todos os segredos!)
az keyvault delete --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP"

# Purgar o Key Vault (remoção permanente)
az keyvault purge --name "$SEU_KEYVAULT_NAME" --location "$SUA_LOCALIZACAO"

# Deletar a Managed Identity
az identity delete --name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP"

# Deletar o grupo Azure AD
az ad group delete --group "$SEU_GROUP_NAME"

# Deletar o Resource Group (CUIDADO - isso remove TODOS os recursos do grupo!)
az group delete --name "$SEU_RESOURCE_GROUP" --yes --no-wait
```

### 5.4. 🧹 Limpar configuração local do kubectl

```bash
# Remover o contexto do kubectl (opcional)
kubectl config delete-context "$SEU_AKS_NAME"

# Remover o cluster da configuração do kubectl (opcional)
kubectl config delete-cluster "$SEU_AKS_NAME"

# Remover o usuário da configuração do kubectl (opcional)
kubectl config delete-user "clusterUser_${SEU_RESOURCE_GROUP}_${SEU_AKS_NAME}"
```

### 5.5. 🗑️ Remover arquivos criados

```bash
# Remover os arquivos YAML criados
rm -f service-account.yaml secret-store.yaml external-secret.yaml
```

> **⚠️ AVISO IMPORTANTE:**
> - Os comandos de cleanup removem PERMANENTEMENTE todos os recursos criados.
> - Tenha certeza de que não precisa mais desses recursos antes de executar os comandos.
> - O comando `az group delete` remove TODOS os recursos do Resource Group.
> - Faça backup de qualquer dado importante antes de executar a limpeza.

---

## 📋 Script Completo (Opcional)

Para facilitar a execução, você pode salvar todos os comandos em um script:

```bash
#!/bin/bash

# Defina suas variáveis
export SEU_GROUP_NAME="akv-access-group"
export SEU_IDENTITY_MANAGED_NAME="test-aks-akv"
export SEU_RESOURCE_GROUP="Embracon-Test"
export SEU_KEYVAULT_NAME="akv-test-embracon"
export SUA_LOCALIZACAO="brazilsouth"
export SEU_AKS_NAME="aks-test"
export SERVICE_ACCOUNT_NAME="workload-identity-sa"
export NAMESPACE="default"
export SECRET_NAME="secretx"

# Login e subscription
echo "🔑 Fazendo login no Azure..."
az login
az account set --subscription "<SUA_SUBSCRIPTION_ID>"

export TENANT_ID="$(az account show --query tenantId -o tsv)"

# Criar recursos do Azure
echo "🏗️ Criando recursos do Azure..."
az group create --name "$SEU_RESOURCE_GROUP" --location "$SUA_LOCALIZACAO"
az ad group create --display-name "$SEU_GROUP_NAME" --mail-nickname "$SEU_GROUP_NAME"
az identity create --name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --location "$SUA_LOCALIZACAO"

export IDENTITY_PRINCIPAL_ID=$(az identity show --name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query principalId -o tsv)
export CLIENT_ID=$(az identity show --name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query clientId -o tsv)

az ad group member add --group "$SEU_GROUP_NAME" --member-id "$IDENTITY_PRINCIPAL_ID"
az keyvault create --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP" --location "$SUA_LOCALIZACAO" --enable-rbac-authorization true
az role assignment create --assignee "$(az ad signed-in-user show --query id -o tsv)" --role "Key Vault Administrator" --scope $(az keyvault show --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query id -o tsv)

export KEY_VAULT_URL=$(az keyvault show --name "$SEU_KEYVAULT_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query properties.vaultUri -o tsv)

# Criar AKS
echo "☁️ Criando cluster AKS..."
az aks create --name "$SEU_AKS_NAME" --resource-group "$SEU_RESOURCE_GROUP" --location "$SUA_LOCALIZACAO" --enable-oidc-issuer --enable-managed-identity --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 3 --tier free --generate-ssh-keys

export AKS_OIDC_ISSUER=$(az aks show --name "$SEU_AKS_NAME" --resource-group "$SEU_RESOURCE_GROUP" --query "oidcIssuerProfile.issuerUrl" -o tsv)

# Configurar federação de identidade
echo "🔄 Configurando federação de identidade..."
export SUBJECT="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}"
az identity federated-credential create --name "kubernetes-federated-credential" --identity-name "$SEU_IDENTITY_MANAGED_NAME" --resource-group "$SEU_RESOURCE_GROUP" --issuer "$AKS_OIDC_ISSUER" --subject "$SUBJECT"

# Conectar ao cluster
echo "🔗 Conectando ao cluster..."
az aks get-credentials --name "$SEU_AKS_NAME" --resource-group "$SEU_RESOURCE_GROUP"

echo "✅ Setup completo! Agora você pode continuar com os passos restantes do tutorial."
```

Salve como `setup-akv-aks.sh` e execute com:

```bash
chmod +x setup-akv-aks.sh
./setup-akv-aks.sh
```
