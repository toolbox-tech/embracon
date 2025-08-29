
<p align="center">
    <img src="../../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Guia Completo: Integração Microsoft Entra ID (Azure AD) com AKS

Este guia cobre o passo a passo para integrar o Microsoft Entra ID ao Azure Kubernetes Service (AKS), com exemplos práticos, comandos de teste e melhores práticas de segurança.


## 📋 Pré-requisitos

```bash
# Permissões necessárias:
# - Application Administrator OU Global Administrator no Azure AD

# Instalar CLI do Azure e kubectl
az aks install-cli
az version
kubectl version --client
```


## 🚀 Criação ou Atualização do Cluster AKS

### Novo cluster com Entra ID

#### Bash
```bash
az group create --name meu-grupo-recursos --location eastus2
az ad group create --display-name "AKS Cluster Admins" --mail-nickname "aks-cluster-admins"
ADMIN_GROUP_ID=$(az ad group show --group "AKS Cluster Admins" --query id -o tsv)
az aks create \
    --resource-group meu-grupo-recursos \
    --name meu-cluster-aks \
    --enable-aad \
    --aad-admin-group-object-ids $ADMIN_GROUP_ID \
    --aad-tenant-id $(az account show --query tenantId -o tsv) \
    --enable-azure-rbac \
    --network-plugin azure \
    --node-vm-size "Standard_B2s" \
    --node-count 3
```

#### PowerShell
```powershell
az group create --name meu-grupo-recursos --location eastus2
az ad group create --display-name "AKS Cluster Admins" --mail-nickname "aks-cluster-admins"
$Env:ADMIN_GROUP_ID = az ad group show --group "AKS Cluster Admins" --query id -o tsv
az aks create `
    --resource-group meu-grupo-recursos `
    --name meu-cluster-aks `
    --enable-aad `
    --aad-admin-group-object-ids $Env:ADMIN_GROUP_ID `
    --aad-tenant-id (az account show --query tenantId -o tsv) `
    --enable-azure-rbac `
    --network-plugin azure `
    --node-vm-size "Standard_B2s" `
    --node-count 3
```

### Atualizar cluster existente

#### Bash
```bash
az aks update \
    --resource-group meu-grupo-recursos \
    --name meu-cluster-aks \
    --enable-aad \
    --aad-admin-group-object-ids $ADMIN_GROUP_ID \
    --enable-azure-rbac
```

#### PowerShell
```powershell
az aks update `
    --resource-group meu-grupo-recursos `
    --name meu-cluster-aks `
    --enable-aad `
    --aad-admin-group-object-ids $Env:ADMIN_GROUP_ID `
    --enable-azure-rbac
```


## 👥 Gerenciamento de Grupos no Entra ID

### Bash
```bash
# Criar grupos para diferentes níveis de acesso
az ad group create --display-name "AKS Cluster Admins" --mail-nickname "aks-cluster-admins"
az ad group create --display-name "AKS Dev Namespace Users" --mail-nickname "aks-dev-namespace-users"
az ad group create --display-name "AKS Read-Only Users" --mail-nickname "aks-read-only-users"

# Adicionar usuários aos grupos
az ad group member add --group "AKS Cluster Admins" --member-id <ID-do-usuario>
az ad group member add --group "AKS Dev Namespace Users" --member-id <ID-do-usuario>
az ad group member add --group "AKS Read-Only Users" --member-id <ID-do-usuario>
```

### PowerShell
```powershell
# Criar grupos para diferentes níveis de acesso
az ad group create --display-name "AKS Cluster Admins" --mail-nickname "aks-cluster-admins"
az ad group create --display-name "AKS Dev Namespace Users" --mail-nickname "aks-dev-namespace-users"
az ad group create --display-name "AKS Read-Only Users" --mail-nickname "aks-read-only-users"

# Adicionar usuários aos grupos
$Env:USER_ID = "<ID-do-usuario>"
az ad group member add --group "AKS Cluster Admins" --member-id $Env:USER_ID
az ad group member add --group "AKS Dev Namespace Users" --member-id $Env:USER_ID
az ad group member add --group "AKS Read-Only Users" --member-id $Env:USER_ID
```

## 🛡️ Configuração de RBAC para Grupos

### Bash
```bash
# Obter ID do recurso do cluster
CLUSTER_ID=$(az aks show --resource-group meu-grupo-recursos --name meu-cluster-aks --query id -o tsv)

# Atribuir função de admin para o grupo de admins
ADMIN_GROUP_ID=$(az ad group show --group "AKS Cluster Admins" --query id -o tsv)
az role assignment create --role "Azure Kubernetes Service RBAC Cluster Admin" --assignee-object-id $ADMIN_GROUP_ID --assignee-principal-type Group --scope $CLUSTER_ID

# Criar namespace dev se necessário
kubectl create namespace dev

# Atribuir acesso ao namespace dev para o grupo de desenvolvedores
DEV_GROUP_ID=$(az ad group show --group "AKS Dev Namespace Users" --query id -o tsv)
az role assignment create --role "Azure Kubernetes Service RBAC Writer" --assignee-object-id $DEV_GROUP_ID --assignee-principal-type Group --scope $CLUSTER_ID/namespaces/dev

# Atribuir acesso somente leitura para todo o cluster
READER_GROUP_ID=$(az ad group show --group "AKS Read-Only Users" --query id -o tsv)
az role assignment create --role "Azure Kubernetes Service RBAC Reader" --assignee-object-id $READER_GROUP_ID --assignee-principal-type Group --scope $CLUSTER_ID
```

### PowerShell
```powershell
# Obter ID do recurso do cluster
$Env:CLUSTER_ID = az aks show --resource-group meu-grupo-recursos --name meu-cluster-aks --query id -o tsv

# Atribuir função de admin para o grupo de admins
$Env:ADMIN_GROUP_ID = az ad group show --group "AKS Cluster Admins" --query id -o tsv
az role assignment create --role "Azure Kubernetes Service RBAC Cluster Admin" --assignee-object-id $Env:ADMIN_GROUP_ID --assignee-principal-type Group --scope $Env:CLUSTER_ID

# Criar namespace dev se necessário
kubectl create namespace dev

# Atribuir acesso ao namespace dev para o grupo de desenvolvedores
$Env:DEV_GROUP_ID = az ad group show --group "AKS Dev Namespace Users" --query id -o tsv
az role assignment create --role "Azure Kubernetes Service RBAC Writer" --assignee-object-id $Env:DEV_GROUP_ID --assignee-principal-type Group --scope "$Env:CLUSTER_ID/namespaces/dev"

# Atribuir acesso somente leitura para todo o cluster
$Env:READER_GROUP_ID = az ad group show --group "AKS Read-Only Users" --query id -o tsv
az role assignment create --role "Azure Kubernetes Service RBAC Reader" --assignee-object-id $Env:READER_GROUP_ID --assignee-principal-type Group --scope $Env:CLUSTER_ID
```


## 🔑 Configurar Credenciais e Testar Acesso

### Bash
```bash
# Obter as credenciais do cluster com suporte a Azure AD (usuário comum)
az aks get-credentials --resource-group meu-grupo-recursos --name meu-cluster-aks --overwrite-existing

# Para acesso admin (importante para usuários do grupo de administradores)
az aks get-credentials --resource-group meu-grupo-recursos --name meu-cluster-aks --admin --overwrite-existing

# Testar acesso (inicia o fluxo de login Azure AD)
kubectl get nodes
```

### PowerShell
```powershell
# Obter as credenciais do cluster com suporte a Azure AD (usuário comum)
az aks get-credentials --resource-group meu-grupo-recursos --name meu-cluster-aks --overwrite-existing

# Para acesso admin (importante para usuários do grupo de administradores)
az aks get-credentials --resource-group meu-grupo-recursos --name meu-cluster-aks --admin --overwrite-existing

# Testar acesso (inicia o fluxo de login Azure AD)
kubectl get nodes

# Armazenar token em variável de ambiente (opcional)
$Env:TOKEN = az aks get-token --resource-group meu-grupo-recursos --name meu-cluster-aks -o tsv
kubectl get nodes --token=$Env:TOKEN
```


## 🔒 Recursos Adicionais de Segurança

```bash
# Habilitar políticas de acesso condicional no portal Azure:
# Microsoft Entra ID > Segurança > Acesso Condicional

# Habilitar MFA para acesso ao cluster:
# Microsoft Entra ID > Segurança > Autenticação
```


## 🧪 Testes de Permissões e Troubleshooting

### Bash
```bash
# Verificar integração Azure AD
az aks show --resource-group meu-grupo-recursos --name meu-cluster-aks --query aadProfile

# Verificar atribuições de função
az role assignment list --scope $CLUSTER_ID --query "[].{principalName:principalName, roleDefinitionName:roleDefinitionName, scope:scope}"

# Testar permissões de grupos
kubectl auth can-i get pods --as=usuario@dominio.com --as-group=$ADMIN_GROUP_ID
kubectl auth can-i create pods --as=usuario@dominio.com --as-group=$READER_GROUP_ID

# Caso um usuário tenha problemas de acesso:
kubectl get clusterrole
kubectl describe clusterrole cluster-admin

# Se receber erro "Forbidden": obtenha credenciais com flag --admin
az aks get-credentials --resource-group meu-grupo-recursos --name meu-cluster-aks --admin --overwrite-existing
```

### PowerShell
```powershell
# Verificar integração Azure AD
az aks show --resource-group meu-grupo-recursos --name meu-cluster-aks --query aadProfile

# Verificar atribuições de função
az role assignment list --scope $Env:CLUSTER_ID --query "[].{principalName:principalName, roleDefinitionName:roleDefinitionName, scope:scope}"

# Testar permissões de grupos
kubectl auth can-i get pods --as=usuario@dominio.com --as-group=$Env:ADMIN_GROUP_ID
kubectl auth can-i create pods --as=usuario@dominio.com --as-group=$Env:READER_GROUP_ID

# Caso um usuário tenha problemas de acesso:
kubectl get clusterrole
kubectl describe clusterrole cluster-admin

# Se receber erro "Forbidden": obtenha credenciais com flag --admin
az aks get-credentials --resource-group meu-grupo-recursos --name meu-cluster-aks --admin --overwrite-existing

# Depurar configuração kubeconfig
$Env:KUBECONFIG_CONTENT = Get-Content ~/.kube/config -Raw
Write-Output $Env:KUBECONFIG_CONTENT
```


## ✅ Melhores Práticas de Segurança

1. **Sempre use grupos em vez de usuários individuais** para atribuição de funções
2. **Implemente MFA** para todos os usuários com acesso ao cluster
3. **Configure políticas de acesso condicional** para restringir acesso de redes não confiáveis
4. **Revise regularmente** as atribuições de acesso
5. **Use o princípio de privilégio mínimo** ao conceder permissões
6. **Documente todos os grupos e roles criados**
7. **Teste permissões com `kubectl auth can-i`**
8. **Audite acessos e revise logs periodicamente**

---

<p align="center">
    <img src="../../../img/toolbox-footer.png" alt="Toolbox Footer" width="200"/>
</p>