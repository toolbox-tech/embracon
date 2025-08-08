# Guia para acessar um segredo no Azure Key Vault (AKV) a partir do Azure Kubernetes Service (AKS)

Este guia apresenta um passo a passo para acessar segredos do Azure Key Vault (AKV) a partir do Azure Kubernetes Service (AKS) de forma segura, utilizando a Federação de Identidade de Carga de Trabalho (Workload Identity Federation) via OIDC, External Secrets Operator e RBAC do Azure.

## Visão Geral

- **Elimina o "Secret Zero"**: Não é necessário armazenar secrets fixos no cluster.
- **Segurança aprimorada**: O acesso é feito por tokens temporários emitidos via OIDC.
- **Automação**: Permissões dinâmicas para workloads, sem rotacionar secrets manualmente.
- **Gerenciamento centralizado**: RBAC do Azure AD controla o acesso aos segredos.

---

## 1. Conceitos-Chave

- **Secret Zero**: Segredo inicial que, se exposto, compromete todo o acesso. Eliminado com OIDC.
- **OIDC (OpenID Connect)**: Protocolo de autenticação que permite ao AKS emitir tokens para workloads.
- **Workload Identity Federation**: Permite que pods do AKS assumam identidades do Azure AD sem secrets.
- **External Secrets Operator**: Sincroniza segredos do AKV para o Kubernetes.
- **RBAC do Azure**: Gerencia quem pode acessar quais segredos no AKV.

---

## 2. Pré-requisitos

- Azure CLI configurado (`az login`)
- Permissões para criar recursos no Azure (AKS, Key Vault, Managed Identity, Grupos)
- Helm instalado para deploy do External Secrets Operator

---

## 3. Fluxo Resumido

1. Crie um grupo no Azure AD para controle de acesso.
2. Crie uma Managed Identity para workloads do AKS.
3. Adicione a Managed Identity ao grupo criado.
4. Crie o Key Vault com RBAC habilitado.
5. Crie ou atualize o cluster AKS com OIDC habilitado.
6. Configure a federação de identidade entre o AKS e a Managed Identity.
7. Instale o External Secrets Operator no cluster.
8. Crie a ServiceAccount no Kubernetes com as anotações necessárias.
9. Crie o SecretStore apontando para o Key Vault.
10. Conceda permissões de acesso ao grupo no Key Vault.
11. Crie o recurso ExternalSecret para sincronizar segredos do AKV para o Kubernetes.

---

## 4. Passo a Passo

### 4.1. Faça login e defina a subscription

Antes de iniciar, faça login no Azure CLI e defina a subscription correta:

```bash
az login
az account set --subscription "<SUA_SUBSCRIPTION_ID>"
```

Substitua `<SUA_SUBSCRIPTION_ID>` pelo ID da subscription desejada.

### 4.2. Defina Variáveis

```bash
$Env:SEU_GROUP_NAME="akv-access-group"
$Env:SEU_IDENTITY_MANAGED_NAME="test-aks-akv"
$Env:SEU_RESOURCE_GROUP="Embracon-Test"
$Env:SEU_KEYVAULT_NAME="akv-test-embracon"
$Env:SUA_LOCALIZACAO="brazilsouth"
$Env:SEU_AKS_NAME="aks-test"
$Env:SERVICE_ACCOUNT_NAME="workload-identity-sa"
$Env:NAMESPACE="default"
$Env:TENANT_ID="$(az account show --query tenantId -o tsv)"
$Env:SECRET_NAME="secretx"
```

### 4.3. Crie os Recursos no Azure

```bash
# Resource Group
az group create --name "$Env:SEU_RESOURCE_GROUP" --location "$Env:SUA_LOCALIZACAO"

# Grupo de acesso
az ad group create --display-name "$Env:SEU_GROUP_NAME" --mail-nickname "$Env:SEU_GROUP_NAME"

# Managed Identity
az identity create --name "$Env:SEU_IDENTITY_MANAGED_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --location "$Env:SUA_LOCALIZACAO"

# Obtenha o Principal ID e Client ID da Managed Identity
$Env:IDENTITY_PRINCIPAL_ID = az identity show --name "$Env:SEU_IDENTITY_MANAGED_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --query principalId -o tsv
$Env:CLIENT_ID = az identity show --name "$Env:SEU_IDENTITY_MANAGED_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --query clientId -o tsv

# Adicione a Managed Identity ao grupo
az ad group member add --group "$Env:SEU_GROUP_NAME" --member-id "$Env:IDENTITY_PRINCIPAL_ID"

# Crie um Key Vault com RBAC
az keyvault create --name "$Env:SEU_KEYVAULT_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --location "$Env:SUA_LOCALIZACAO" --enable-rbac-authorization true

# Após criar o KeyVault, você deve dar permissões aos usuários para poderem usá-lo

# Conceda permissão de "Administrador do Cofre de Chaves" ao usuário no Key Vault, este comando dará a permissão ao usuário logado para administrar o Key Vault recém-criado.
az role assignment create --assignee "$(az ad signed-in-user show --query id -o tsv)" --role "Key Vault Administrator" --scope $(az keyvault show --name "$Env:SEU_KEYVAULT_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --query id -o tsv)

# Obtenha a URL do Vault
$Env:KEY_VAULT_URL = az keyvault show --name "$Env:SEU_KEYVAULT_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --query properties.vaultUri -o tsv
```

### 4.4. Crie ou Atualize o AKS com OIDC

**Novo cluster:**
```bash
az aks create --name "$Env:SEU_AKS_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --location "$Env:SUA_LOCALIZACAO" --enable-oidc-issuer --enable-managed-identity --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 3 --tier free --generate-ssh-keys
```

**Cluster existente:**
```bash
az aks update --name "$Env:SEU_AKS_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --enable-oidc-issuer
```

Descubra o issuer URL do OIDC:
```bash
$Env:AKS_OIDC_ISSUER = az aks show --name "$Env:SEU_AKS_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --query "oidcIssuerProfile.issuerUrl" -o tsv
```

### 4.5. Configure a Federação de Identidade

```bash
# Crie o subject
$Env:subject="system:serviceaccount:"+$Env:NAMESPACE+":$Env:SERVICE_ACCOUNT_NAME"

az identity federated-credential create --name "kubernetes-federated-credential" --identity-name "$Env:SEU_IDENTITY_MANAGED_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --issuer "$Env:AKS_OIDC_ISSUER" --subject "$Env:subject"
```

### 4.6 Conecte-se ao cluster criado

```bash
az aks get-credentials --name "$Env:SEU_AKS_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP"
```

### 4.7.1 Adcione o Repo do External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
```

### 4.7.2 Adcione o Repo do External Secrets Operator

```bash
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
```

> Nota
>
> É necessário ter o [Helm](https://helm.sh/docs/intro/install/) instalado.

### 4.8. Crie a ServiceAccount no Kubernetes

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

> **Nota:**  
> - Substitua `<CLIENT_ID>` pelo valor da variável `$Env:CLIENT_ID`.
> - Substitua `<TENANT_ID>` pelo valor da variável `$Env:TENANT_ID`.

```bash
kubectl apply -f service-account.yaml
```

### 4.9. Crie o Secret Store

Crie um arquivo `secret-store.yaml` com o seguinte conteúdo, substituindo os valores conforme necessário:

```yaml
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: akv-secret-manager-store
  namespace: <namespace>
spec:
  provider:
    azurekv:
      authType: WorkloadIdentity
      vaultUrl: "<KEY_VAULT_URL>"
      serviceAccountRef:
        name: workload-identity-sa
```

> **Nota:**  
> - Substitua `<namespace>` pelo namespace desejado no cluster Kubernetes (por exemplo, `default` se estiver usando o namespace padrão).
> - Substitua `<KEY_VAULT_URL>` pelo valor da variável `$Env:KEY_VAULT_URL`.

Aplique o recurso:

```bash
kubectl apply -f secret-store.yaml
```

### 4.10. Conceda Permissões no Key Vault

No portal do Azure ou via CLI, atribua a função **Usuário de Segredos do Cofre de Chaves** ao grupo `$Env:SEU_GROUP_NAME` no Key Vault para ter acesso a todos os Segredos do Cofre.

Caso queira dar acesso somente a um segredo específico, vá até o segredo, clique no mesmo, acesse Controle de acesso IAM e adicione a função **Usuário de Segredos do Cofre de Chaves** ao grupo `$Env:SEU_GROUP_NAME`.

Conceda permissão de "Usuário de Segredos do Cofre de Chaves" ao grupo no Key Vault via CLI, assim ele poderá ver todos os secrets
```bash
az role assignment create --assignee-object-id $(az ad group show --group "$Env:SEU_GROUP_NAME" --query id -o tsv) --assignee-principal-type Group --role "Key Vault Secrets User" --scope $(az keyvault show --name "$Env:SEU_KEYVAULT_NAME" --resource-group "$Env:SEU_RESOURCE_GROUP" --query id -o tsv)
```

Se desejar conceder acesso apenas a um segredo específico, siga os passos abaixo para atribuir a função **Usuário de Segredos do Cofre de Chaves** ao grupo apenas no escopo do segredo desejado:

#### Crie o secret

```bash
az keyvault secret set --vault-name "$Env:SEU_KEYVAULT_NAME" --name "$Env:SECRET_NAME" --value "TESTE"
```

> Nota
>
> A criação do segredo se faz necessária somente para fins de exemplificação.

![0](anexos/img/0.png)

![1](anexos/img/1.png)

![2](anexos/img/2.png)

![3](anexos/img/3.png)

![4](anexos/img/4.png)

### 4.11. Crie o External Secret 

Crie um arquivo `external-secret.yaml` com o seguinte conteúdo, substituindo os valores conforme necessário:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: akv-external-secret-manager-store
  namespace: <namespace>
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
        key: <nome-do-segredo-no-akv>
```

> **Nota:**  
> - Substitua `<namespace>` pelo namespace desejado no cluster Kubernetes (por exemplo, `default` se estiver usando o namespace padrão).
> - Substitua `nome-do-segredo-no-akv` pelo nome do segredo existente no Key Vault que deseja sincronizar.
> - O campo `secretKey` define o nome da chave no Secret do Kubernetes.

Aplique o recurso:

```bash
kubectl apply -f external-secret.yaml
```
### 4.12 Visualizando o Secrets

Para visualizar o Secret criado no Kubernetes, utilize o comando abaixo, substituindo `<namespace>` pelo namespace utilizado (por exemplo, `default`):

```bash
kubectl get secret my-app-secret-k8s-akv -n default
```

Para exibir o conteúdo do Secret (decodificando o valor):

```bash
kubectl get secret my-app-secret-k8s-akv -n default -o jsonpath="{.data.my-akv-secret-key}" | %{ [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

> **Nota:**  
> - O nome `my-app-secret-k8s-akv` corresponde ao campo `.spec.target.name` definido no recurso `ExternalSecret`.
> - O campo `my-akv-secret-key` corresponde ao campo `.spec.data.secretKey` do `ExternalSecret`.
