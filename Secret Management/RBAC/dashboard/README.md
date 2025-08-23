<p align="center">
  <img src="../../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Kubernetes Dashboard: Instalação, Uso e Segurança


Esta documentação abrange como instalar, configurar, usar e principalmente **proteger** o Kubernetes Dashboard seguindo as melhores práticas de segurança.

## 📋 Índice

- [🚀 Instalação do Dashboard](#-instalação-do-dashboard)
- [🔐 Configuração de Segurança](#-configuração-de-segurança)
- [🌐 Acesso ao Dashboard](#-acesso-ao-dashboard)
- [👤 Gerenciamento de Usuários](#-gerenciamento-de-usuários)
- [� Integração com Microsoft Entra ID (Azure AD)](#-integração-com-microsoft-entra-id-azure-ad)
- [�🛡️ Melhores Práticas de Segurança](#️-melhores-práticas-de-segurança)
- [🔧 Troubleshooting](#-troubleshooting)

## 🚀 Instalação do Dashboard

### Método Recomendado: Helm

O Kubernetes Dashboard agora suporta **apenas instalação via Helm** para melhor controle de dependências:

```bash
# Adicionar o repositório oficial
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

# Instalar o Dashboard
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --create-namespace \
  --namespace kubernetes-dashboard
```

### Verificação da Instalação

```bash
# Verificar pods do Dashboard
kubectl get pods -n kubernetes-dashboard

# Verificar serviços
kubectl get svc -n kubernetes-dashboard
```

## 🔐 Configuração de Segurança

### ⚠️ Aviso de Segurança Importante

> **O Dashboard implementa configuração mínima de RBAC por padrão.** Para proteger seus dados do cluster, você deve configurar autenticação adequada.

### 1. Criar Service Account de Administração

```yaml
# dashboard-admin-user.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```

### 2. Criar ClusterRoleBinding

```yaml
# dashboard-admin-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

### 3. Aplicar Configurações

```bash
# Aplicar as configurações
kubectl apply -f dashboard-admin-user.yaml
kubectl apply -f dashboard-admin-rolebinding.yaml
```

## 🌐 Acesso ao Dashboard

### 1. Configurar Port-Forward

```bash
# Fazer port-forward para o Dashboard (HTTPS obrigatório)
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

### 2. Acessar via Browser

Acesse: **https://localhost:8443**

> ⚠️ **Importante**: O login via token **APENAS funciona via HTTPS**. HTTP não é suportado para autenticação.

### 3. Obter Token de Autenticação

#### Token Temporário (Recomendado)

```bash
# Gerar token temporário
kubectl -n kubernetes-dashboard create token admin-user
```

#### Token de Longa Duração (Use com Cuidado)

```yaml
# admin-user-token.yaml
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token
```

```bash
# Aplicar o Secret
kubectl apply -f admin-user-token.yaml

# Obter o token
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath="{.data.token}" | base64 -d
```

## 👤 Gerenciamento de Usuários

### Usuário com Acesso Limitado (Read-Only)

Para criar usuários com permissões limitadas, use esta abordagem:

```yaml
# readonly-user.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-readonly
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dashboard-readonly
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["extensions"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-readonly
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dashboard-readonly
subjects:
- kind: ServiceAccount
  name: dashboard-readonly
  namespace: kubernetes-dashboard
```

### Usuário com Acesso por Namespace

```yaml
# namespace-user.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev-user
  namespace: dev
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: dev-user-role
  namespace: dev
rules:
- apiGroups: ["", "apps", "extensions"]
  resources: ["*"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-user-binding
  namespace: dev
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: dev-user-role
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
```

## 🔐 Integração com Microsoft Entra ID (Azure AD)

Para clusters AKS, você pode integrar o Dashboard diretamente com Microsoft Entra ID para autenticação mais robusta e gerenciamento centralizado de identidades.

### ⚠️ Importante

> **Microsoft Entra ID** (anteriormente Azure Active Directory) oferece integração nativa com AKS, eliminando a necessidade de gerenciar tokens manualmente.

### Pré-requisitos

- **Azure CLI** versão 2.29.0 ou superior
- **kubectl** versão mínima 1.18.1 
- **kubelogin** para autenticação
- **Grupo do Microsoft Entra ID** para administradores do cluster

```bash
# Verificar versões
az --version
kubectl version --client

# Instalar kubelogin (se necessário)
az aks install-cli
```

### 0. Criar Grupo de Administradores (Obrigatório)

> ⚠️ **Importante**: Você **deve** ter um grupo do Microsoft Entra ID antes de habilitar a integração.

```bash
# Criar grupo para administradores do cluster
az ad group create \
    --display-name "AKS-Cluster-Admins" \
    --mail-nickname "aks-cluster-admins" \
    --description "Administradores do cluster AKS"

# Obter o Object ID do grupo (anote este valor!)
GROUP_ID=$(az ad group show --group "AKS-Cluster-Admins" --query id -o tsv)
echo "Group Object ID: $GROUP_ID"

# Adicionar usuários ao grupo
az ad group member add \
    --group "AKS-Cluster-Admins" \
    --member-id <user-object-id>

# Verificar membros do grupo
az ad group member list --group "AKS-Cluster-Admins" --output table
```

### 1. Criar Cluster AKS com Entra ID

#### Novo Cluster

```bash
# Criar grupo de recursos
az group create --name myResourceGroup --location centralus

# Criar cluster com integração Entra ID (sem downtime)
az aks create \
    --resource-group myResourceGroup \
    --name myManagedCluster \
    --enable-aad \
    --aad-admin-group-object-ids $GROUP_ID \
    --aad-tenant-id <tenant-id> \
    --generate-ssh-keys

# Verificar configuração do AAD Profile
az aks show \
    --resource-group myResourceGroup \
    --name myManagedCluster \
    --query aadProfile -o table
```

#### Cluster Existente

> ⚠️ **AVISO CRÍTICO - POSSÍVEL INDISPONIBILIDADE**
> 
> - **Clusters de camada gratuita**: Podem ter **tempo de inatividade** do servidor de API durante a atualização
> - **Clusters pagos**: Geralmente **zero downtime**, mas pode haver breve instabilidade
> - **Recomendação**: Execute durante **janela de manutenção** ou horário de baixo uso
> - **kubeconfig**: Será **alterado** após a atualização - você precisará executar `az aks get-credentials` novamente

```bash
# ⚠️ EXECUTE EM JANELA DE MANUTENÇÃO ⚠️
# Habilitar integração em cluster existente
az aks update \
    --resource-group myResourceGroup \
    --name myManagedCluster \
    --enable-aad \
    --aad-admin-group-object-ids $GROUP_ID \
    --aad-tenant-id <tenant-id>

# ✅ OBRIGATÓRIO: Atualizar kubeconfig após a mudança
az aks get-credentials \
    --resource-group myResourceGroup \
    --name myManagedCluster \
    --overwrite-existing
```

#### Migrar Cluster Legado (Azure AD v1)

> ⚠️ **AVISO DE MIGRAÇÃO**
> 
> - **Tempo de inatividade**: Esperado para clusters de camada gratuita
> - **Alteração de kubeconfig**: Formato será modificado
> - **Não reversível**: Não há suporte para downgrade
> - **Teste primeiro**: Execute em ambiente não-produtivo

```bash
# ⚠️ MIGRAÇÃO COM POSSÍVEL DOWNTIME ⚠️
az aks update \
    --resource-group myResourceGroup \
    --name myManagedCluster \
    --enable-aad \
    --aad-admin-group-object-ids $GROUP_ID \
    --aad-tenant-id <tenant-id>

# Verificar resultado da migração
az aks show \
    --resource-group myResourceGroup \
    --name myManagedCluster \
    --query aadProfile
```

### 2. Configurar Acesso ao Cluster

```bash
# Obter credenciais do cluster
az aks get-credentials --resource-group myResourceGroup --name myManagedCluster

# Configurar kubelogin
kubelogin convert-kubeconfig -l azurecli

# Testar acesso
kubectl get nodes
```

### 3. Integrar Dashboard com Entra ID

#### Configurar RBAC para Grupos do Entra ID

```yaml
# entra-id-dashboard-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-admin-entra-id
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: Group
  name: "<object-id-do-grupo-admin>"  # Object ID do grupo Entra ID
  apiGroup: rbac.authorization.k8s.io
```

#### Configurar Usuário Read-Only via Entra ID

```yaml
# entra-id-readonly-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dashboard-readonly-entra
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps", "extensions"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-readonly-entra-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dashboard-readonly-entra
subjects:
- kind: Group
  name: "<object-id-grupo-readonly>"  # Object ID do grupo read-only
  apiGroup: rbac.authorization.k8s.io
```

### 4. Obter Token via Entra ID

```bash
# Token via CLI do Azure (recomendado)
az account get-access-token --resource https://management.azure.com/

# Ou usar kubelogin diretamente
kubectl proxy --port=8001 &
# Abrir: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### 5. Autenticação Não-Interativa

Para pipelines CI/CD e automação:

```bash
# Via Service Principal
kubelogin convert-kubeconfig -l spn

# Configurar variáveis de ambiente
export AAD_SERVICE_PRINCIPAL_CLIENT_ID=<client-id>
export AAD_SERVICE_PRINCIPAL_CLIENT_SECRET=<client-secret>
export AAD_TENANT_ID=<tenant-id>

# Via Managed Identity
kubelogin convert-kubeconfig -l msi
```

### 6. Gerenciar Grupos e Permissões

#### Criar Grupo de Administradores

```bash
# Criar grupo para admins do Dashboard
az ad group create \
    --display-name "AKS-Dashboard-Admins" \
    --mail-nickname "aks-dashboard-admins" \
    --description "Administradores do Kubernetes Dashboard"

# Adicionar usuários ao grupo
az ad group member add \
    --group "AKS-Dashboard-Admins" \
    --member-id <user-object-id>
```

#### Configurar Permissões por Namespace

```yaml
# namespace-specific-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: dashboard-prod-viewer
rules:
- apiGroups: ["", "apps", "extensions"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dashboard-prod-viewer-binding
  namespace: production
subjects:
- kind: Group
  name: "<prod-viewers-group-id>"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dashboard-prod-viewer
  apiGroup: rbac.authorization.k8s.io
```

### 7. Troubleshooting Entra ID

#### Problema: "Error getting token"

```bash
# Verificar login no Azure
az login

# Reconfigurar kubelogin
kubelogin convert-kubeconfig -l azurecli

# Verificar grupos do usuário
az ad signed-in-user list-owned-objects
```

#### Problema: "Forbidden" com Entra ID

```bash
# Verificar permissões do grupo
kubectl auth can-i "*" "*" --as-group=<group-object-id>

# Verificar configuração do cluster
az aks show --resource-group myResourceGroup --name myManagedCluster --query aadProfile
```

#### Problema: kubelogin não encontrado

```bash
# Instalar kubelogin
az aks install-cli

# Ou download manual
curl -LO https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip
unzip kubelogin-linux-amd64.zip
sudo mv bin/linux_amd64/kubelogin /usr/local/bin/
```

### 8. Limitações e Considerações Importantes

- ⚠️ **Não pode ser desabilitada** após habilitação
- ⚠️ **Não há suporte para downgrade** para clusters legados
- ⚠️ **Requer RBAC habilitado** no cluster
- ⚠️ **Kubernetes 1.24+** usa formato exec por padrão

#### ⚠️ **Impactos de Disponibilidade**

| Operação | Cluster Gratuito | Cluster Pago | Recomendação |
|----------|------------------|--------------|--------------|
| **Novo Cluster** | ✅ Sem impacto | ✅ Sem impacto | Qualquer horário |
| **Cluster Existente** | ⚠️ Possível downtime | ⚠️ Breve instabilidade | Janela de manutenção |
| **Migração Legado** | 🔴 Downtime esperado | ⚠️ Possível impacto | Janela de manutenção obrigatória |

#### 📋 **Checklist Pré-Habilitação**

```bash
# 1. Verificar se cluster tem RBAC habilitado
az aks show --resource-group myResourceGroup --name myManagedCluster --query enableRbac

# 2. Verificar tier do cluster (Free vs Paid)
az aks show --resource-group myResourceGroup --name myManagedCluster --query sku

# 3. Criar grupo de admins ANTES da habilitação
az ad group create --display-name "AKS-Admins" --mail-nickname "aks-admins"

# 4. Planejar janela de manutenção para clusters existentes
# 5. Comunicar equipe sobre possível indisponibilidade
# 6. Ter rollback plan (não aplicável - operação irreversível)
```

### 9. Vantagens da Integração Entra ID

| Recurso | Benefício |
|---------|-----------|
| **SSO** | Login único com credenciais corporativas |
| **MFA** | Autenticação multi-fator automática |
| **Conditional Access** | Políticas de acesso baseadas em contexto |
| **Group Management** | Gerenciamento centralizado via Entra ID |
| **Audit Logs** | Logs centralizados no Azure AD |
| **Token Management** | Renovação automática de tokens |

```bash
# Aplicar configurações
kubectl apply -f entra-id-dashboard-rbac.yaml
kubectl apply -f entra-id-readonly-rbac.yaml
kubectl apply -f namespace-specific-rbac.yaml

## 🛡️ Melhores Práticas de Segurança

### 1. Princípio do Menor Privilégio

```yaml
# Exemplo: Usuário específico para monitoramento
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dashboard-monitoring
rules:
- apiGroups: [""]
  resources: ["pods", "services", "nodes"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list"]
```

### 2. Rotação Regular de Tokens

```bash
# Script para rotacionar tokens
#!/bin/bash
NAMESPACE="kubernetes-dashboard"
SERVICE_ACCOUNT="admin-user"

# Deletar token antigo
kubectl delete secret ${SERVICE_ACCOUNT} -n ${NAMESPACE} --ignore-not-found=true

# Criar novo token
kubectl create secret generic ${SERVICE_ACCOUNT} \
  --from-literal=token="$(kubectl create token ${SERVICE_ACCOUNT} -n ${NAMESPACE})" \
  -n ${NAMESPACE}

echo "Token rotacionado com sucesso!"
```

### 3. Configuração de Rede Segura

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: dashboard-netpol
  namespace: kubernetes-dashboard
spec:
  podSelector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 8443
```

### 4. Auditoria e Monitoramento

```yaml
# audit-policy.yaml (para configurar no kube-apiserver)
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  namespaces: ["kubernetes-dashboard"]
  resources:
  - group: ""
    resources: ["secrets", "serviceaccounts"]
  - group: "rbac.authorization.k8s.io"
    resources: ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
```

## 🔧 Troubleshooting

### 1. Erro: "Invalid Token"

**Problema**: Token não aceito na interface de login.

**Soluções**:
```bash
# Verificar se está acessando via HTTPS
# ❌ http://localhost:8443 - NÃO FUNCIONARÁ
# ✅ https://localhost:8443 - CORRETO

# Gerar novo token
kubectl -n kubernetes-dashboard create token admin-user

# Verificar se Service Account existe
kubectl get sa admin-user -n kubernetes-dashboard
```

### 2. Erro: "Forbidden" no Dashboard

**Problema**: Usuário sem permissões adequadas.

**Soluções**:
```bash
# Verificar permissões do usuário
kubectl auth can-i "*" "*" --as=system:serviceaccount:kubernetes-dashboard:admin-user

# Verificar ClusterRoleBinding
kubectl describe clusterrolebinding admin-user

# Recriar binding se necessário
kubectl delete clusterrolebinding admin-user
kubectl apply -f dashboard-admin-rolebinding.yaml
```

### 3. Dashboard Não Carrega

**Problema**: Interface não carrega ou apresenta erros.

**Soluções**:
```bash
# Verificar status dos pods
kubectl get pods -n kubernetes-dashboard

# Ver logs do Dashboard
kubectl logs -n kubernetes-dashboard deployment/kubernetes-dashboard

# Verificar port-forward
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

### 4. Problemas de Certificado SSL

**Problema**: Erros de certificado no browser.

**Soluções**:
```bash
# Aceitar certificado self-signed no browser
# Ou configurar certificado válido:

# Gerar certificado para o Dashboard
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout dashboard.key -out dashboard.crt \
  -subj "/CN=kubernetes-dashboard"

# Criar secret com certificado
kubectl create secret tls kubernetes-dashboard-certs \
  --key dashboard.key --cert dashboard.crt \
  -n kubernetes-dashboard
```

## 📊 Recursos do Dashboard

### 1. Visão Administrativa
- **Nodes**: CPU e memória agregados
- **Namespaces**: Overview de recursos
- **PersistentVolumes**: Armazenamento do cluster

### 2. Workloads
- **Deployments**: Status e especificações
- **ReplicaSets**: Pods controlados
- **StatefulSets**: Aplicações com estado
- **DaemonSets**: Pods em todos os nodes

### 3. Networking
- **Services**: Exposição de serviços
- **Ingress**: Roteamento externo
- **Network Policies**: Controle de tráfego

### 4. Storage
- **PersistentVolumeClaims**: Requisições de armazenamento
- **StorageClasses**: Classes de armazenamento

### 5. Configuration
- **ConfigMaps**: Configurações de aplicação
- **Secrets**: Dados sensíveis
- **Resource Quotas**: Limites de recursos

## 🔄 Limpeza de Recursos

### Remover Usuário Admin

```bash
# Remover Service Account e ClusterRoleBinding
kubectl -n kubernetes-dashboard delete serviceaccount admin-user
kubectl delete clusterrolebinding admin-user

# Remover secrets (se criados)
kubectl -n kubernetes-dashboard delete secret admin-user
```

### Desinstalar Dashboard

```bash
# Via Helm
helm uninstall kubernetes-dashboard -n kubernetes-dashboard

# Remover namespace
kubectl delete namespace kubernetes-dashboard
```

## 📚 Referências

- [Documentação Oficial do Kubernetes Dashboard](https://github.com/kubernetes/dashboard)
- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kubernetes Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)
- [Kubernetes Authorization](https://kubernetes.io/docs/reference/access-authn-authz/authorization/)
- [Microsoft Entra ID Integration with AKS](https://learn.microsoft.com/pt-br/azure/aks/enable-authentication-microsoft-entra-id)
- [Azure AD RBAC with Kubernetes](https://learn.microsoft.com/pt-br/azure/aks/azure-ad-rbac)
- [Kubelogin Authentication Methods](https://learn.microsoft.com/pt-br/azure/aks/kubelogin-authentication)
- [AKS Identity and Access Concepts](https://learn.microsoft.com/pt-br/azure/aks/concepts-identity)

## 🏷️ Tags

`kubernetes-dashboard` `rbac` `security` `authentication` `web-ui` `cluster-management`

**Soluções DevOps & Cloud para acelerar sua jornada digital**

*Kubernetes • Azure • Security • Automation*

<p align="center">
  <strong>🚀 Kubernetes Dashboard Security & Management 🛡️</strong><br>
  <em>🔐 RBAC • Authentication • Best Practices</em>
</p>