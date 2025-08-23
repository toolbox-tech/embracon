# Keycloak no Kubernetes: Instalação, Configuração e Gerenciamento

<div align="center">
  <img src="../../../img/tbx.png" alt="Toolbox Logo" width="200"/>
  <br><br>
  <strong>Embracon Toolbox - DevOps & Cloud Solutions</strong>
</div>

Esta documentação abrange como instalar, configurar e gerenciar o **Keycloak** como provedor de identidade em clusters Kubernetes, incluindo integração com RBAC e gerenciamento centralizado de usuários.

## 📋 Índice

- [🚀 O que é Keycloak](#-o-que-é-keycloak)
- [🏗️ Instalação no Kubernetes](#️-instalação-no-kubernetes)
- [🔐 Configuração Inicial](#-configuração-inicial)
- [👥 Gerenciamento de Usuários](#-gerenciamento-de-usuários)
- [🔗 Integração com Kubernetes RBAC](#-integração-com-kubernetes-rbac)
- [🛡️ Configurações de Segurança](#️-configurações-de-segurança)
- [🔧 Troubleshooting](#-troubleshooting)

## 🚀 O que é Keycloak

**Keycloak** é uma solução open-source de gerenciamento de identidade e acesso que oferece:

### 🔑 **Principais Funcionalidades:**
- **Single Sign-On (SSO)** - Login único para múltiplas aplicações
- **Identity Brokering** - Integração com provedores externos (LDAP, Active Directory, Google, etc.)
- **User Federation** - Sincronização com sistemas existentes
- **Fine-grained Authorization** - Controle granular de permissões
- **Standard Protocols** - Suporte a OpenID Connect, OAuth 2.0, SAML 2.0
- **Multi-tenancy** - Múltiplos realms isolados

### 🎯 **Casos de Uso no Kubernetes:**
- **Autenticação centralizada** para cluster Kubernetes
- **SSO** para aplicações no cluster
- **Integração RBAC** com grupos e roles
- **API Gateway** authentication
- **Microservices** security

## 🏗️ Instalação no Kubernetes

### Método 1: Helm Chart (Recomendado)

```bash
# Adicionar repositório do Keycloak
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Criar namespace
kubectl create namespace keycloak

# Instalar Keycloak
helm install keycloak bitnami/keycloak \
  --namespace keycloak \
  --set auth.adminUser=admin \
  --set auth.adminPassword=admin123 \
  --set postgresql.auth.postgresPassword=postgres123 \
  --set service.type=ClusterIP \
  --set ingress.enabled=true \
  --set ingress.hostname=keycloak.local
```

### Método 2: Operator (Produção)

```bash
# Instalar Keycloak Operator
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/main/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/main/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml

# Criar namespace
kubectl create namespace keycloak

# Deploy Keycloak via Operator
cat <<EOF | kubectl apply -f -
apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
metadata:
  name: keycloak
  namespace: keycloak
spec:
  instances: 1
  db:
    vendor: postgres
    host: postgres-service
    usernameSecret:
      name: keycloak-db-secret
      key: username
    passwordSecret:
      name: keycloak-db-secret
      key: password
  http:
    tlsSecret: keycloak-tls-secret
  hostname:
    hostname: keycloak.example.com
  ingress:
    enabled: true
EOF
```

### Método 3: Manifests Personalizados

```yaml
# keycloak-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
      - name: keycloak
        image: quay.io/keycloak/keycloak:23.0.3
        args: ["start-dev"]
        env:
        - name: KEYCLOAK_ADMIN
          value: "admin"
        - name: KEYCLOAK_ADMIN_PASSWORD
          value: "admin123"
        - name: KC_PROXY
          value: "edge"
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /realms/master
            port: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
  namespace: keycloak
spec:
  selector:
    app: keycloak
  ports:
  - name: http
    port: 8080
    targetPort: 8080
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak
  namespace: keycloak
  annotations:
    nginx.ingress.kubernetes.io/proxy-buffer-size: "128k"
    nginx.ingress.kubernetes.io/proxy-buffers-number: "4"
spec:
  rules:
  - host: keycloak.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: keycloak
            port:
              number: 8080
```

### Verificar Instalação

```bash
# Verificar pods
kubectl get pods -n keycloak

# Verificar serviços
kubectl get svc -n keycloak

# Verificar ingress
kubectl get ingress -n keycloak

# Logs do Keycloak
kubectl logs -n keycloak deployment/keycloak
```

## 🔐 Configuração Inicial

### 1. Acesso ao Admin Console

```bash
# Port-forward para acesso local
kubectl port-forward -n keycloak svc/keycloak 8080:8080

# Acessar: http://localhost:8080
# Login: admin / admin123
```

### 2. Criar Realm para Kubernetes

```bash
# Via Admin Console:
# 1. Master realm -> Dropdown -> Add Realm
# 2. Name: "kubernetes"
# 3. Enabled: ON
# 4. Create
```

### 3. Configurar Client para Kubernetes

```json
{
  "clientId": "kubernetes",
  "name": "Kubernetes Cluster",
  "protocol": "openid-connect",
  "clientAuthenticatorType": "client-secret",
  "secret": "kubernetes-client-secret",
  "redirectUris": [
    "http://localhost:8000",
    "https://kubernetes-dashboard.local/*"
  ],
  "webOrigins": [
    "https://kubernetes-dashboard.local"
  ],
  "publicClient": false,
  "bearerOnly": false,
  "consentRequired": false,
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": true,
  "serviceAccountsEnabled": false,
  "frontchannelLogout": true,
  "fullScopeAllowed": true,
  "attributes": {
    "saml.assertion.signature": "false",
    "saml.force.post.binding": "false",
    "saml.multivalued.roles": "false",
    "saml.encrypt": "false",
    "saml_force_name_id_format": "false",
    "saml.client.signature": "false",
    "tls.client.certificate.bound.access.tokens": "false",
    "saml.authnstatement": "false",
    "display.on.consent.screen": "false",
    "saml.onetimeuse.condition": "false"
  }
}
```

### 4. Configurar Mappers

```bash
# Criar Group Mapper
# Client -> kubernetes -> Mappers -> Create
# Name: "groups"
# Mapper Type: "Group Membership"
# Token Claim Name: "groups"
# Full group path: OFF
# Add to ID token: ON
# Add to access token: ON
```

## 👥 Gerenciamento de Usuários

### 1. Criar Grupos

```bash
# Via Admin Console:
# Realm: kubernetes -> Groups -> New

# Criar grupos hierárquicos:
# - admins
#   - cluster-admins
#   - namespace-admins
# - developers
#   - dev-team
#   - qa-team
# - viewers
#   - read-only
```

### 2. Criar Usuários

```json
{
  "username": "john.doe",
  "email": "john.doe@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "enabled": true,
  "emailVerified": true,
  "credentials": [
    {
      "type": "password",
      "value": "password123",
      "temporary": false
    }
  ],
  "groups": [
    "/developers/dev-team"
  ],
  "attributes": {
    "department": ["engineering"],
    "location": ["sao-paulo"]
  }
}
```

### 3. Bulk Import via REST API

```bash
# Obter token admin
ADMIN_TOKEN=$(curl -s -X POST http://keycloak.local:8080/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin123" | jq -r '.access_token')

# Criar usuário via API
curl -X POST http://keycloak.local:8080/admin/realms/kubernetes/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "api-user",
    "email": "api-user@example.com",
    "enabled": true,
    "credentials": [
      {
        "type": "password",
        "value": "password123",
        "temporary": false
      }
    ]
  }'
```

### 4. Configurar User Federation

#### LDAP Integration

```json
{
  "providerId": "ldap",
  "providerType": "org.keycloak.storage.UserStorageProvider",
  "name": "ldap-provider",
  "config": {
    "connectionUrl": ["ldap://ldap.example.com:389"],
    "usersDn": ["ou=users,dc=example,dc=com"],
    "bindDn": ["cn=admin,dc=example,dc=com"],
    "bindCredential": ["admin-password"],
    "userObjectClasses": ["inetOrgPerson, organizationalPerson"],
    "usernameLDAPAttribute": ["uid"],
    "rdnLDAPAttribute": ["uid"],
    "uuidLDAPAttribute": ["entryUUID"],
    "userLDAPFilter": [""],
    "searchScope": ["1"],
    "validatePasswordPolicy": ["false"],
    "trustEmail": ["false"],
    "useTruststoreSpi": ["ldapsOnly"],
    "connectionPooling": ["true"],
    "pagination": ["true"],
    "allowKerberosAuthentication": ["false"],
    "debug": ["false"],
    "useKerberosForPasswordAuthentication": ["false"]
  }
}
```

## 🔗 Integração com Kubernetes RBAC

### 1. Configurar OIDC no API Server

```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
spec:
  containers:
  - command:
    - kube-apiserver
    - --oidc-issuer-url=http://keycloak.local:8080/realms/kubernetes
    - --oidc-client-id=kubernetes
    - --oidc-username-claim=preferred_username
    - --oidc-groups-claim=groups
    - --oidc-ca-file=/etc/ssl/certs/ca-certificates.crt
```

### 2. Criar RBAC Bindings

```yaml
# cluster-admin-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: keycloak-cluster-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: Group
  name: /admins/cluster-admins
  apiGroup: rbac.authorization.k8s.io
---
# namespace-admin-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: keycloak-namespace-admins
  namespace: development
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: Group
  name: /admins/namespace-admins
  apiGroup: rbac.authorization.k8s.io
---
# developers-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: keycloak-developers
  namespace: development
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: developer-role
subjects:
- kind: Group
  name: /developers
  apiGroup: rbac.authorization.k8s.io
```

### 3. Configurar kubectl para OIDC

```bash
# Instalar oidc-login plugin
kubectl krew install oidc-login

# Configurar kubeconfig
kubectl config set-credentials oidc \
  --exec-api-version=client.authentication.k8s.io/v1beta1 \
  --exec-command=kubectl \
  --exec-arg=oidc-login \
  --exec-arg=get-token \
  --exec-arg=--oidc-issuer-url=http://keycloak.local:8080/realms/kubernetes \
  --exec-arg=--oidc-client-id=kubernetes \
  --exec-arg=--oidc-client-secret=kubernetes-client-secret

# Usar contexto OIDC
kubectl config set-context oidc \
  --cluster=kubernetes \
  --user=oidc

kubectl config use-context oidc
```

## 🛡️ Configurações de Segurança

### 1. Configurar TLS

```yaml
# keycloak-tls-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-tls-secret
  namespace: keycloak
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi...  # Base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi...  # Base64 encoded private key
```

### 2. Configurar Políticas de Senha

```json
{
  "passwordPolicy": "length(8) and digits(1) and lowerCase(1) and upperCase(1) and specialChars(1) and notUsername",
  "attributes": {
    "bruteForceProtected": "true",
    "maxFailureWaitSeconds": "900",
    "minimumQuickLoginWaitSeconds": "60",
    "waitIncrementSeconds": "60",
    "quickLoginCheckMilliSeconds": "1000",
    "maxDeltaTimeSeconds": "43200",
    "failureFactor": "30"
  }
}
```

### 3. Configurar Autenticação Multi-Fator

```bash
# Habilitar OTP
# Realm Settings -> Authentication -> Flows -> Browser
# Add OTP Form execution
# Set to REQUIRED
```

### 4. Configurar Auditoria

```json
{
  "eventsEnabled": true,
  "eventsExpiration": 604800,
  "eventsListeners": ["jboss-logging"],
  "enabledEventTypes": [
    "LOGIN",
    "LOGIN_ERROR",
    "LOGOUT",
    "USER_INFO_REQUEST",
    "PERMISSION_TOKEN",
    "CODE_TO_TOKEN",
    "REFRESH_TOKEN"
  ],
  "adminEventsEnabled": true,
  "adminEventsDetailsEnabled": true
}
```

## 🔧 Troubleshooting

### 1. Keycloak não inicia

```bash
# Verificar logs
kubectl logs -n keycloak deployment/keycloak

# Problemas comuns:
# - Banco de dados não acessível
# - Configuração de proxy incorreta
# - Recursos insuficientes

# Verificar recursos
kubectl describe pod -n keycloak -l app=keycloak
```

### 2. Autenticação OIDC falha

```bash
# Verificar configuração do API server
kubectl describe pod -n kube-system kube-apiserver

# Testar conectividade do Keycloak
curl -k http://keycloak.local:8080/realms/kubernetes/.well-known/openid_configuration

# Verificar certificados
openssl s_client -connect keycloak.local:443 -showcerts
```

### 3. Usuários não conseguem autenticar

```bash
# Verificar grupos no token
# Admin Console -> Realm Settings -> Keys -> RS256 -> Certificate
# Usar jwt.io para decodificar token

# Verificar RBAC bindings
kubectl get clusterrolebinding,rolebinding --all-namespaces | grep keycloak

# Testar permissões
kubectl auth can-i get pods --as=system:user:john.doe --as-group=/developers/dev-team
```

### 4. Performance Issues

```bash
# Verificar métricas
kubectl top pod -n keycloak

# Configurar recursos adequados
kubectl patch deployment keycloak -n keycloak -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "keycloak",
            "resources": {
              "requests": {"memory": "1Gi", "cpu": "500m"},
              "limits": {"memory": "2Gi", "cpu": "1000m"}
            }
          }
        ]
      }
    }
  }
}'
```

### 5. Backup e Restore

```bash
# Backup do banco de dados
kubectl exec -n keycloak deployment/postgres -- pg_dump -U keycloak keycloak > keycloak-backup.sql

# Export de realm
curl -X GET "http://keycloak.local:8080/admin/realms/kubernetes" \
  -H "Authorization: Bearer $ADMIN_TOKEN" > kubernetes-realm-export.json

# Import de realm
curl -X POST "http://keycloak.local:8080/admin/realms" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d @kubernetes-realm-export.json
```

## 📊 Monitoramento e Métricas

### 1. Configurar Prometheus Metrics

```yaml
# keycloak-servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: keycloak
  namespace: keycloak
spec:
  selector:
    matchLabels:
      app: keycloak
  endpoints:
  - port: http
    path: /metrics
```

### 2. Dashboard Grafana

```json
{
  "dashboard": {
    "title": "Keycloak Metrics",
    "panels": [
      {
        "title": "Active Sessions",
        "type": "stat",
        "targets": [
          {
            "expr": "keycloak_user_sessions_total"
          }
        ]
      },
      {
        "title": "Login Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(keycloak_logins_total[5m])"
          }
        ]
      }
    ]
  }
}
```

## 📚 Referências

- [Documentação Oficial do Keycloak](https://www.keycloak.org/documentation)
- [Keycloak Kubernetes Examples](https://github.com/keycloak/keycloak-quickstarts)
- [Kubernetes OIDC Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens)
- [Keycloak REST API](https://www.keycloak.org/docs-api/latest/rest-api/index.html)
- [Keycloak Helm Chart](https://github.com/bitnami/charts/tree/master/bitnami/keycloak)

## 🏷️ Tags

`keycloak` `kubernetes` `oidc` `sso` `identity-management` `rbac` `authentication`

---

<div align="center">
  
## 📞 Suporte e Contato

**Embracon Toolbox Team**  
🌐 [toolbox-tech.embracon.com](https://toolbox-tech.embracon.com)  
📧 toolbox@embracon.com.br  
🔗 [GitHub](https://github.com/toolbox-tech) | [LinkedIn](https://linkedin.com/company/embracon)

---

### 🛠️ Desenvolvido com ❤️ pela Embracon Toolbox

<p align="center">
  <strong>🔐 Keycloak Identity & Access Management 🚀</strong><br>
  <em>🔑 SSO • OIDC • RBAC Integration</em>
</p>

<img src="../../../img/tbx.png" alt="Toolbox Logo" width="100"/>

**© 2025 Embracon Toolbox. Todos os direitos reservados.**

</div>
