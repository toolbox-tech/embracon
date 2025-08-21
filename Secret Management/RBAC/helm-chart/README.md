# External Secrets RBAC Helm Chart

Este Helm Chart implanta uma configuração completa de RBAC para External Secrets Operator com Azure Key Vault.

## 📦 Instalação

### Pré-requisitos

1. **Helm 3.x** instalado
2. **External Secrets Operator** instalado no cluster
3. **Azure Workload Identity** configurado
4. **Azure Key Vault** com secrets configurados

### Instalação Básica

```bash
# Instalar no ambiente de desenvolvimento
helm install external-secrets-rbac ./helm-chart

# Instalar com valores personalizados
helm install external-secrets-rbac ./helm-chart -f ./helm-chart/values.yaml

# Instalar em produção
helm install external-secrets-rbac-prod ./helm-chart -f ./helm-chart/values-prod.yaml
```

### Instalação por Ambiente

```bash
# Desenvolvimento
helm install dev-external-secrets ./helm-chart \
  --namespace dev \
  --create-namespace \
  --values ./helm-chart/values.yaml

# Produção
helm install prod-external-secrets ./helm-chart \
  --namespace production \
  --create-namespace \
  --values ./helm-chart/values-prod.yaml
```

## ⚙️ Configuração

### Valores Principais

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| `global.namespace` | Namespace de destino | `dev` |
| `serviceAccounts.app.name` | Nome da SA da aplicação | `app-alpha-sa` |
| `azureKeyVault.secretStore.vaultUrl` | URL do Azure Key Vault | `""` |
| `rbac.create` | Criar recursos RBAC | `true` |
| `testPod.create` | Criar pod de teste | `false` |

### Exemplo de Customização

```yaml
# custom-values.yaml
global:
  namespace: meu-ambiente

serviceAccounts:
  azureKv:
    annotations:
      azure.workload.identity/client-id: "SEU-CLIENT-ID"
      azure.workload.identity/tenant-id: "SEU-TENANT-ID"

azureKeyVault:
  secretStore:
    vaultUrl: "https://meu-keyvault.vault.azure.net/"
  externalSecret:
    data:
      - secretKey: database-password
        remoteRef:
          key: db-password
      - secretKey: api-key
        remoteRef:
          key: api-secret
```

## 🚀 Comandos Úteis

### Deploy e Upgrade

```bash
# Fazer upgrade do release
helm upgrade external-secrets-rbac ./helm-chart

# Fazer upgrade com novos valores
helm upgrade external-secrets-rbac ./helm-chart -f new-values.yaml

# Ver diferenças antes do upgrade
helm diff upgrade external-secrets-rbac ./helm-chart -f new-values.yaml
```

### Debugging

```bash
# Ver templates gerados
helm template external-secrets-rbac ./helm-chart

# Ver templates com valores específicos
helm template external-secrets-rbac ./helm-chart -f values-prod.yaml

# Fazer dry-run
helm install external-secrets-rbac ./helm-chart --dry-run --debug
```

### Gerenciamento

```bash
# Listar releases
helm list

# Ver status do release
helm status external-secrets-rbac

# Ver histórico
helm history external-secrets-rbac

# Rollback
helm rollback external-secrets-rbac 1
```

## 🧪 Testes

## 🧪 Testes Validados

### ✅ **Testes de Deploy Realizados:**

```bash
# 1. Clean slate test - Funcionou ✅
kubectl delete namespace dev
helm install external-secrets-rbac ./helm-chart

# 2. Upgrade test - Funcionou ✅  
helm upgrade external-secrets-rbac ./helm-chart --set testPod.create=true

# 3. Rollback capability - Testado ✅
helm rollback external-secrets-rbac 2
```

### ✅ **Testes de Funcionalidade:**

```bash
# RBAC granular funcionando ✅
kubectl auth can-i get secret/rbac-test-secret-k8s-akv --as=system:serviceaccount:dev:app-alpha-sa -n dev
# Resultado: yes

kubectl auth can-i get secrets --as=system:serviceaccount:dev:app-alpha-sa -n dev  
# Resultado: no (conforme esperado)

# Secret sincronizado do Azure Key Vault ✅
kubectl get secret rbac-test-secret-k8s-akv -n dev
# STATUS: Disponível

# Pod consumindo secrets ✅
kubectl exec test-pod -n dev -- sh -c 'echo $MY_SECRET_VALUE'
# OUTPUT: secret

kubectl exec test-pod -n dev -- cat /etc/secrets/my-akv-secret-key
# OUTPUT: secret
```

### ✅ **Status de Validação Completa:**

| Componente | Status | Evidência |
|------------|--------|-----------|
| **Helm Install** | ✅ | Release `external-secrets-rbac` deployed |
| **Namespace** | ✅ | `dev` criado com labels corretas |
| **Service Accounts** | ✅ | 2 SAs criadas com annotations Azure |
| **RBAC** | ✅ | Role + RoleBinding funcionando |
| **SecretStore** | ✅ | Status: `Valid`, Ready: `True` |
| **ExternalSecret** | ✅ | Status: `SecretSynced`, Ready: `True` |
| **K8s Secret** | ✅ | Secret `rbac-test-secret-k8s-akv` criado |
| **Pod Test** | ✅ | Consumindo via ENV + Volume Mount |

### 🔧 **Problemas Resolvidos Durante Teste:**

#### ❌→✅ **API Version Issue**
**Problema**: Templates usavam `external-secrets.io/v1beta1`
**Solução**: Atualizado para `external-secrets.io/v1`

#### ❌→✅ **External Secrets Cache**  
**Problema**: Operator não encontrava SecretStore após limpeza
**Solução**: Restart do pod do operator

#### ❌→✅ **Azure Key Vault URL**
**Problema**: URL placeholder no values.yaml
**Solução**: URL real `https://kvtest-marcelo-sbx.vault.azure.net/`

### Habilitar Pod de Teste

```yaml
# values.yaml ou via --set
testPod:
  create: true
```

### Executar Testes

```bash
# Instalar com pod de teste
helm install test-release ./helm-chart --set testPod.create=true

# Verificar pod de teste
kubectl logs test-pod -n dev

# Limpar teste
helm uninstall test-release
```

## 🔧 Desenvolvimento

### Validar Chart

```bash
# Lint do chart
helm lint ./helm-chart

# Validar templates
helm template ./helm-chart --debug

# Testar com diferentes valores
helm template ./helm-chart -f values-prod.yaml --debug
```

### Estrutura do Chart

```
helm-chart/
├── Chart.yaml                 # Metadados do chart
├── values.yaml               # Valores padrão
├── values-prod.yaml          # Valores para produção
├── templates/
│   ├── _helpers.tpl          # Templates helpers
│   ├── namespace.yaml        # Namespace
│   ├── serviceaccount.yaml   # Service Accounts
│   ├── rbac.yaml            # Role e RoleBinding
│   ├── external-secrets.yaml # SecretStore e ExternalSecret
│   └── test-pod.yaml        # Pod de teste (opcional)
```

## 📚 Documentação Adicional

- [Helm Documentation](https://helm.sh/docs/)
- [External Secrets Operator](https://external-secrets.io/)
- [Azure Workload Identity](https://azure.github.io/azure-workload-identity/)

## 🏷️ Tags

`helm` `kubernetes` `external-secrets` `azure-key-vault` `rbac` `gitops`
