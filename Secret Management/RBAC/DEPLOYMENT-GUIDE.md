# Guia de Deployment Completo

Este guia documenta o processo completo de deployment testado e validado.

## 📋 Pré-requisitos

### ✅ **Validações Necessárias:**

```bash
# 1. Helm instalado
helm version

# 2. Kubectl configurado
kubectl cluster-info

# 3. External Secrets Operator instalado
kubectl get crd externalsecrets.external-secrets.io

# 4. Azure Key Vault configurado
# - Key Vault criado: kvtest-marcelo-sbx.vault.azure.net
# - Secret "secretx" com valor "secret"
# - Workload Identity configurado

# 5. Permissões Azure
# - Managed Identity criada
# - Federated credentials configurados
# - Permissões no Key Vault
```

## 🚀 Deployment Step-by-Step

### **Método 1: Helm Chart (Recomendado)**

#### Passo 1: Preparação
```bash
# Clone o repositório
git clone https://github.com/toolbox-tech/embracon
cd "embracon/Secret Management/RBAC"

# Verificar estrutura do Helm Chart
ls -la helm-chart/
```

#### Passo 2: Configuração
```bash
# Editar values.yaml se necessário
vim helm-chart/values.yaml

# Principais configurações:
# - azureKeyVault.secretStore.vaultUrl
# - serviceAccounts.azureKv.annotations (client-id, tenant-id)
# - azureKeyVault.externalSecret.data (secrets a sincronizar)
```

#### Passo 3: Deploy
```bash
# Deploy inicial
helm install external-secrets-rbac ./helm-chart

# Verificar status
helm status external-secrets-rbac
kubectl get all,secrets,externalsecrets,secretstores -n dev
```

#### Passo 4: Validação
```bash
# Aguardar sincronização (pode levar até 30s)
kubectl get externalsecret -n dev -w

# Verificar secret criado
kubectl get secret rbac-test-secret-k8s-akv -n dev

# Testar RBAC
kubectl auth can-i get secret/rbac-test-secret-k8s-akv --as=system:serviceaccount:dev:app-alpha-sa -n dev
```

#### Passo 5: Teste com Pod
```bash
# Habilitar pod de teste
helm upgrade external-secrets-rbac ./helm-chart --set testPod.create=true

# Verificar logs
kubectl logs test-pod -n dev

# Testar consumo
kubectl exec test-pod -n dev -- sh -c 'echo $MY_SECRET_VALUE'
kubectl exec test-pod -n dev -- cat /etc/secrets/my-akv-secret-key
```

### **Método 2: YAML Manual**

#### Passo 1: Deploy em ordem
```bash
# 1. Namespace
kubectl apply -f namespace.yaml

# 2. Service Accounts
kubectl apply -f service-account-app-alpha.yaml
kubectl apply -f service-account-akv.yaml

# 3. RBAC
kubectl apply -f role-secretstore-reader.yaml
kubectl apply -f rolebinding.yaml

# 4. External Secrets
kubectl apply -f secret-store.yaml
kubectl apply -f external-secret.yaml

# 5. Pod de teste (opcional)
kubectl apply -f pod.yaml
```

## 🔍 Troubleshooting Durante Deployment

### ❌ **Problema: ExternalSecret com SecretSyncError**

**Sintomas:**
```bash
kubectl get externalsecret -n dev
# STATUS: SecretSyncError, READY: False
```

**Soluções Testadas:**
```bash
# 1. Verificar logs do operator
kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets

# 2. Reiniciar operator (resolve cache issues)
kubectl delete pod -n external-secrets -l app.kubernetes.io/name=external-secrets

# 3. Recriar ExternalSecret
kubectl delete externalsecret akv-external-secret-test -n dev
helm upgrade external-secrets-rbac ./helm-chart
```

### ❌ **Problema: API Version Error**

**Sintomas:**
```bash
no matches for kind "ExternalSecret" in version "external-secrets.io/v1beta1"
```

**Solução:**
```bash
# Verificar versão correta
kubectl api-resources | grep external

# Usar v1 ao invés de v1beta1 nos templates
```

### ❌ **Problema: RBAC Access Denied**

**Sintomas:**
```bash
kubectl auth can-i get secrets --as=system:serviceaccount:dev:app-alpha-sa -n dev
# Output: no
```

**Validação:**
```bash
# Testar acesso específico (deve funcionar)
kubectl auth can-i get secret/rbac-test-secret-k8s-akv --as=system:serviceaccount:dev:app-alpha-sa -n dev
# Output: yes

# Isso é o comportamento esperado (least privilege)
```

## ✅ Validação Final

### **Checklist de Validação:**

```bash
# 1. ✅ Namespace criado
kubectl get namespace dev
# Status: Active

# 2. ✅ Service Accounts
kubectl get serviceaccounts -n dev
# app-alpha-sa, akv-rbac-test-sa

# 3. ✅ RBAC configurado
kubectl get role,rolebinding -n dev
# secret-reader, app-alpha-can-read-secretstore

# 4. ✅ SecretStore ativo
kubectl get secretstore -n dev
# STATUS: Valid, READY: True

# 5. ✅ ExternalSecret sincronizado
kubectl get externalsecret -n dev
# STATUS: SecretSynced, READY: True

# 6. ✅ Secret K8s criado
kubectl get secret rbac-test-secret-k8s-akv -n dev
# TYPE: Opaque, DATA: 1

# 7. ✅ RBAC granular funcionando
kubectl auth can-i get secret/rbac-test-secret-k8s-akv --as=system:serviceaccount:dev:app-alpha-sa -n dev
# yes

kubectl auth can-i get secrets --as=system:serviceaccount:dev:app-alpha-sa -n dev
# no

# 8. ✅ Pod consumindo secrets
kubectl exec test-pod -n dev -- sh -c 'echo $MY_SECRET_VALUE'
# Output: secret

kubectl exec test-pod -n dev -- cat /etc/secrets/my-akv-secret-key
# Output: secret
```

## 🎯 Deploy para Ambientes

### **Desenvolvimento**
```bash
helm install dev-secrets ./helm-chart \
  --namespace dev \
  --create-namespace \
  --set testPod.create=true
```

### **Produção**
```bash
helm install prod-secrets ./helm-chart \
  --namespace production \
  --create-namespace \
  --values helm-chart/values-prod.yaml \
  --set testPod.create=false
```

### **Staging**
```bash
# Criar values-staging.yaml customizado
helm install staging-secrets ./helm-chart \
  --namespace staging \
  --create-namespace \
  --values helm-chart/values-staging.yaml
```

## 📊 Monitoramento Pós-Deploy

### **Comandos de Monitoramento:**
```bash
# Status geral
helm list
kubectl get all,secrets,externalsecrets,secretstores -n dev

# Logs em tempo real
kubectl logs -f -n external-secrets -l app.kubernetes.io/name=external-secrets

# Eventos
kubectl get events -n dev --sort-by=.metadata.creationTimestamp

# Métricas de refresh
kubectl describe externalsecret akv-external-secret-test -n dev
```

## 🔄 Operações de Manutenção

### **Updates**
```bash
# Atualizar configurações
helm upgrade external-secrets-rbac ./helm-chart \
  --set azureKeyVault.externalSecret.refreshInterval=10s

# Adicionar novos secrets
helm upgrade external-secrets-rbac ./helm-chart \
  --set-string azureKeyVault.externalSecret.data[1].secretKey=new-key \
  --set-string azureKeyVault.externalSecret.data[1].remoteRef.key=new-remote-key
```

### **Rollbacks**
```bash
# Ver histórico
helm history external-secrets-rbac

# Rollback para revisão anterior
helm rollback external-secrets-rbac 2
```

### **Cleanup**
```bash
# Remover deployment
helm uninstall external-secrets-rbac

# Limpar namespace (se necessário)
kubectl delete namespace dev
```

## 📚 Documentação de Referência

- **README principal**: `./README.md` (inclui diagrama de arquitetura)
- **Helm Chart**: `./helm-chart/README.md`  
- **External Secrets**: https://external-secrets.io/
- **Azure Workload Identity**: https://azure.github.io/azure-workload-identity/

Este guia foi testado e validado em ambiente real com todas as funcionalidades funcionando corretamente.
