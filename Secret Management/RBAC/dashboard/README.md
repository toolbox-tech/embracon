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
- [🛡️ Melhores Práticas de Segurança](#️-melhores-práticas-de-segurança)
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

## 🏷️ Tags

`kubernetes-dashboard` `rbac` `security` `authentication` `web-ui` `cluster-management`

**Soluções DevOps & Cloud para acelerar sua jornada digital**

*Kubernetes • Azure • Security • Automation*

<p align="center">
  <strong>🚀 Kubernetes Dashboard Security & Management 🛡️</strong><br>
  <em>🔐 RBAC • Authentication • Best Practices</em>
</p>