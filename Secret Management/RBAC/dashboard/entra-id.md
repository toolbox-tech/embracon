# Como Integrar Microsoft Entra ID (Azure AD) com AKS

Vou fornecer um guia passo a passo completo para integrar o Microsoft Entra ID com o Azure Kubernetes Service:

## Passo 1: Pré-requisitos

```bash
# Verificar se você tem as permissões necessárias no Azure AD
# Você precisa ser pelo menos "Application Administrator" no Azure AD

# Instalar ferramentas necessárias
az aks install-cli
```

## Passo 2: Criar/Atualizar o cluster AKS com integração Azure AD

### Para novo cluster:
```bash
# Criar grupo de recursos se necessário
az group create --name meu-grupo-recursos --location eastus2

# Criar cluster AKS com integração Azure AD
az aks create \
    --resource-group meu-grupo-recursos \
    --name meu-cluster-aks \
    --enable-aad \
    --aad-admin-group-object-ids <ID-do-grupo-admin-AD> \
    --aad-tenant-id <ID-do-tenant-AD> \
    --enable-azure-rbac \
    --network-plugin azure \
    --kubernetes-version 1.27.7 \
    --node-count 3
```

### Para cluster existente:
```bash
# Atualizar cluster existente para usar Azure AD
az aks update \
    --resource-group meu-grupo-recursos \
    --name meu-cluster-aks \
    --enable-aad \
    --aad-admin-group-object-ids <ID-do-grupo-admin-AD> \
    --enable-azure-rbac
```

## Passo 3: Criar grupos no Microsoft Entra ID

```bash
# Criar grupos para diferentes níveis de acesso
az ad group create --display-name "AKS Cluster Admins" --mail-nickname "aks-cluster-admins"
az ad group create --display-name "AKS Dev Namespace Users" --mail-nickname "aks-dev-namespace-users"
az ad group create --display-name "AKS Read-Only Users" --mail-nickname "aks-read-only-users"

# Adicionar usuários aos grupos
az ad group member add --group "AKS Cluster Admins" --member-id <ID-do-usuario>
```

## Passo 4: Configurar RBAC para os grupos

```bash
# Obter ID do recurso do cluster
CLUSTER_ID=$(az aks show \
    --resource-group meu-grupo-recursos \
    --name meu-cluster-aks \
    --query id -o tsv)

# Atribuir função de admin para o grupo de admins
ADMIN_GROUP_ID=$(az ad group show --group "AKS Cluster Admins" --query id -o tsv)
az role assignment create \
    --role "Azure Kubernetes Service RBAC Cluster Admin" \
    --assignee-object-id $ADMIN_GROUP_ID \
    --assignee-principal-type Group \
    --scope $CLUSTER_ID

# Criar namespace dev se necessário
kubectl create namespace dev

# Atribuir acesso ao namespace dev para o grupo de desenvolvedores
DEV_GROUP_ID=$(az ad group show --group "AKS Dev Namespace Users" --query id -o tsv)
az role assignment create \
    --role "Azure Kubernetes Service RBAC Writer" \
    --assignee-object-id $DEV_GROUP_ID \
    --assignee-principal-type Group \
    --scope $CLUSTER_ID/namespaces/dev

# Atribuir acesso somente leitura para todo o cluster
READER_GROUP_ID=$(az ad group show --group "AKS Read-Only Users" --query id -o tsv)
az role assignment create \
    --role "Azure Kubernetes Service RBAC Reader" \
    --assignee-object-id $READER_GROUP_ID \
    --assignee-principal-type Group \
    --scope $CLUSTER_ID
```

## Passo 5: Configurar credenciais e testar acesso

```bash
# Obter as credenciais do cluster com suporte a Azure AD
az aks get-credentials \
    --resource-group meu-grupo-recursos \
    --name meu-cluster-aks \
    --overwrite-existing

# Testar acesso (isso deve iniciar o fluxo de login Azure AD)
kubectl get nodes
```

## Passo 6: Configurar recursos adicionais de segurança

```bash
# Habilitar políticas de acesso condicional no Azure AD
# (Configure isso no portal do Azure em Microsoft Entra ID > Segurança > Acesso Condicional)

# Habilitar MFA para acesso ao cluster
# (Configure isso no portal do Azure em Microsoft Entra ID > Segurança > Autenticação)
```

## Verificação e Solução de Problemas

```bash
# Verificar integração Azure AD
az aks show \
    --resource-group meu-grupo-recursos \
    --name meu-cluster-aks \
    --query aadProfile

# Verificar atribuições de função
az role assignment list \
    --scope $CLUSTER_ID \
    --query "[].{principalName:principalName, roleDefinitionName:roleDefinitionName, scope:scope}"

# Caso um usuário tenha problemas de acesso:
kubectl get clusterrole
kubectl describe clusterrole cluster-admin
```

## Melhores Práticas de Segurança

1. **Sempre use grupos em vez de usuários individuais** para atribuição de funções
2. **Implemente MFA** para todos os usuários com acesso ao cluster
3. **Configure políticas de acesso condicional** para restringir acesso de redes não confiáveis
4. **Revise regularmente** as atribuições de acesso
5. **Use o princípio de privilégio mínimo** ao conceder permissões

Esta implementação garante que seu AKS esteja totalmente integrado com Microsoft Entra ID, permitindo gerenciamento centralizado de identidades e controle de acesso granular ao seu cluster Kubernetes.