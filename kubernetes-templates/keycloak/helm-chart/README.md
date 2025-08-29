# Embracon Toolbox - Keycloak Helm Chart

Este Helm Chart instala e configura o Keycloak para autenticação e autorização em ambientes Kubernetes, integrado com RBAC e External Secrets Operator.

## 📋 Pré-requisitos

- Kubernetes 1.19+
- Helm 3.2.0+
- PostgreSQL (instalado automaticamente como dependência)
- Cert-manager (opcional, para TLS automático)
- Prometheus Operator (opcional, para monitoramento)

## 🚀 Instalação Rápida

```bash
# Adicionar repositório do PostgreSQL
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Instalar Keycloak
helm install keycloak ./helm-chart \
  --namespace keycloak \
  --create-namespace \
  --set networking.hostname=keycloak.exemplo.com \
  --set auth.admin.password=SuaSenhaSegura123
```

## ⚙️ Configuração

### Configurações Essenciais

Edite o arquivo `values.yaml` ou use parâmetros `--set`:

```yaml
# Configurações de rede
networking:
  hostname: keycloak.exemplo.com
  httpsRequired: true

# Credenciais administrativas
auth:
  admin:
    username: admin
    password: "ALTERE-ESTA-SENHA"  # ⚠️ IMPORTANTE: Alterar em produção

# Configuração do banco de dados
database:
  host: ""  # Deixe vazio para usar PostgreSQL interno
  name: keycloak
  username: keycloak
  password: "ALTERE-ESTA-SENHA"  # ⚠️ IMPORTANTE: Alterar em produção
```

### Configuração de Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  tls:
    enabled: true
    secretName: keycloak-tls
```

### Integração RBAC com Kubernetes

```yaml
rbac:
  create: true
  oidcIntegration:
    enabled: true
    realm: kubernetes
    clientId: kubernetes
    groupBindings:
      - group: "k8s-admins"
        clusterRole: cluster-admin
        description: "Administradores do cluster"
      - group: "k8s-developers"
        clusterRole: edit
        description: "Desenvolvedores com acesso de edição"
```

## 📊 Monitoramento

### Prometheus

```yaml
monitoring:
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true
      labels:
        release: prometheus-operator
```

### Dashboards Grafana

O chart inclui alertas pré-configurados para:
- Disponibilidade do serviço
- Taxa de erro de login
- Tempo de resposta
- Uso de memória
- Conexões com banco de dados

## 🔒 Segurança

### Network Policies

```yaml
networkPolicy:
  enabled: true
  ingress:
    enabled: true
    namespaceSelector:
      matchLabels:
        name: ingress-nginx
```

### Pod Security Context

```yaml
keycloak:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop:
        - ALL
```

## 🧪 Testes

Execute os testes do Helm para validar a instalação:

```bash
# Executar todos os testes
helm test keycloak -n keycloak

# Testar conectividade básica
kubectl logs -n keycloak -l test-type=helm-test

# Testar banco de dados
kubectl logs -n keycloak -l test-type=database-test

# Testar integração OIDC
kubectl logs -n keycloak -l test-type=oidc-test
```

## 📁 Estrutura do Chart

```
helm-chart/
├── Chart.yaml                    # Metadados do chart
├── values.yaml                   # Configurações padrão
├── templates/
│   ├── _helpers.tpl              # Funções auxiliares
│   ├── configmap.yaml            # Configurações do Keycloak
│   ├── deployment.yaml           # Deployment principal
│   ├── service.yaml              # Serviços (normal e headless)
│   ├── ingress.yaml              # Exposição externa
│   ├── secrets.yaml              # Credenciais sensíveis
│   ├── serviceaccount.yaml       # Conta de serviço
│   ├── rbac.yaml                 # Permissões RBAC
│   ├── monitoring.yaml           # ServiceMonitor e PrometheusRule
│   ├── policies.yaml             # PDB, NetworkPolicy, HPA
│   └── tests/
│       └── test-connection.yaml  # Testes automatizados
```

## 🔧 Comandos Úteis

### Instalação Personalizada

```bash
# Instalação completa com monitoramento
helm install keycloak ./helm-chart \
  --namespace keycloak \
  --create-namespace \
  --set networking.hostname=keycloak.empresa.com \
  --set auth.admin.password=MinhasenhaSegura123 \
  --set ingress.enabled=true \
  --set monitoring.prometheus.enabled=true

# Instalação mínima para desenvolvimento
helm install keycloak ./helm-chart \
  --namespace keycloak \
  --create-namespace \
  --set networking.hostname=keycloak.local \
  --set networking.httpsRequired=false \
  --set ingress.enabled=false
```

### Upgrade

```bash
# Atualizar configurações
helm upgrade keycloak ./helm-chart \
  --namespace keycloak \
  --set keycloak.replicas=3

# Upgrade com backup
helm upgrade keycloak ./helm-chart \
  --namespace keycloak \
  --wait \
  --timeout=600s
```

### Troubleshooting

```bash
# Verificar status dos pods
kubectl get pods -n keycloak

# Ver logs do Keycloak
kubectl logs -n keycloak deployment/keycloak -f

# Verificar configurações aplicadas
helm get values keycloak -n keycloak

# Debug do template
helm template keycloak ./helm-chart --debug

# Port-forward para acesso local
kubectl port-forward -n keycloak svc/keycloak 8080:8080
```

## 🌐 Acesso

Após a instalação:

1. **Admin Console**: `https://seu-hostname/admin`
   - Usuário: `admin` (ou configurado em `auth.admin.username`)
   - Senha: Definida em `auth.admin.password`

2. **OIDC Endpoints**:
   - Discovery: `https://seu-hostname/realms/{realm}/.well-known/openid_configuration`
   - Certs: `https://seu-hostname/realms/{realm}/protocol/openid-connect/certs`

3. **Health Checks**:
   - Health: `https://seu-hostname/health`
   - Metrics: `https://seu-hostname:9000/metrics` (se habilitado)

## ⚠️ Notas Importantes

1. **Senhas Padrão**: Altere TODAS as senhas padrão antes de usar em produção
2. **TLS**: Configure certificados adequados para ambientes produção
3. **Backup**: Configure backup regular do banco PostgreSQL
4. **Recursos**: Ajuste limits/requests conforme sua carga de trabalho
5. **Alta Disponibilidade**: Use múltiplas réplicas e PDB em produção

## 📚 Documentação Adicional

- [Documentação Completa do Keycloak](../README.md)
- [Configuração RBAC para Kubernetes](../../README.md)
- [Integração com External Secrets](../../external-secrets/)
- [Monitoramento e Alertas](../monitoring/)

## 🆘 Suporte

Para suporte e dúvidas:
- Consulte a documentação no repositório Embracon Toolbox
- Verifique os logs dos containers
- Execute os testes do Helm para diagnóstico
- Revise as configurações de rede e DNS

---
**Embracon Toolbox** - Soluções corporativas para Kubernetes e DevOps
