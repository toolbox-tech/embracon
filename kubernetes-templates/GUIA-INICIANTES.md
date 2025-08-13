# 🎓 Guia Passo a Passo: Kubernetes Health Checks e Autoscaling

## 📚 Índice
1. [Pré-requisitos](#-pré-requisitos)
2. [Conceitos Básicos](#-conceitos-básicos)
3. [Preparando sua Aplicação](#-preparando-sua-aplicação)
4. [Deploy com Helm (Recomendado)](#-deploy-com-helm-recomendado)
5. [Deploy sem Helm (YAML direto)](#-deploy-sem-helm-yaml-direto)
6. [Verificando se está Funcionando](#-verificando-se-está-funcionando)
7. [Troubleshooting](#-troubleshooting)
8. [Próximos Passos](#-próximos-passos)

---

## 🛠️ Pré-requisitos

### O que você precisa ter instalado:

#### 1. **Kubectl** (Cliente Kubernetes)
```bash
# Windows (usando Chocolatey)
choco install kubernetes-cli

# macOS (usando Homebrew)
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### 2. **Helm** (Gerenciador de pacotes K8s)
```bash
# Windows
choco install kubernetes-helm

# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### 3. **Acesso a um cluster Kubernetes**
Você precisa de um destes:
- **Local**: Docker Desktop, Minikube, Kind
- **Cloud**: Azure AKS, AWS EKS, Google GKE
- **Empresa**: Cluster corporativo

#### 4. **Verificar se está conectado**
```bash
# Testar conexão
kubectl cluster-info

# Ver nós do cluster
kubectl get nodes

# Ver contexto atual
kubectl config current-context
```

---

## 💡 Conceitos Básicos

### 🏥 Health Checks (Verificações de Saúde)

#### **Liveness Probe** 🔄
- **O que faz**: Verifica se o container está "vivo"
- **Quando usar**: Para detectar travamentos, deadlocks
- **O que acontece se falhar**: Kubernetes **reinicia** o container
- **Exemplo**: Verificar se processo principal está rodando

#### **Readiness Probe** 🚦
- **O que faz**: Verifica se está pronto para receber tráfego
- **Quando usar**: Para verificar dependências (banco, cache)
- **O que acontece se falhar**: Kubernetes **para de enviar** tráfego
- **Exemplo**: Verificar se consegue conectar no banco

#### **Startup Probe** 🚀
- **O que faz**: Protege durante inicialização lenta
- **Quando usar**: Apps que demoram muito para inicializar
- **O que acontece se falhar**: Container é considerado falho
- **Exemplo**: Apps Java pesados, bancos de dados

### 📈 Autoscaling (Escalamento Automático)

#### **HPA (Horizontal Pod Autoscaler)** ↔️
- **O que faz**: Aumenta/diminui **número de pods**
- **Baseado em**: CPU, Memória, métricas customizadas
- **Exemplo**: Se CPU > 70%, criar mais pods

#### **VPA (Vertical Pod Autoscaler)** ↕️
- **O que faz**: Aumenta/diminui **recursos** dos pods
- **Baseado em**: Histórico de uso
- **Exemplo**: Mudar de 512MB para 1GB de RAM

---

## 🏗️ Preparando sua Aplicação

### Passo 1: Adicionar Health Check na sua app

#### Para uma API Python (Flask):
```python
# health.py
from flask import Flask, jsonify
import psutil

app = Flask(__name__)

@app.route('/health')
def health():
    """Liveness probe - verifica se app está viva"""
    try:
        # Verificação simples - se chegou aqui, está vivo
        return jsonify({
            "status": "healthy",
            "service": "minha-api"
        }), 200
    except:
        return jsonify({"status": "unhealthy"}), 503

@app.route('/ready')
def ready():
    """Readiness probe - verifica se está pronto"""
    try:
        # Verificar banco de dados (exemplo)
        # db.execute("SELECT 1")
        
        # Verificar cache (exemplo)
        # redis_client.ping()
        
        return jsonify({
            "status": "ready",
            "dependencies": {
                "database": True,
                "cache": True
            }
        }), 200
    except:
        return jsonify({
            "status": "not_ready",
            "dependencies": {
                "database": False,
                "cache": False
            }
        }), 503

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

#### Para uma API Java (Spring Boot):
```java
@RestController
public class HealthController {
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("service", "minha-api");
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> ready() {
        Map<String, Object> response = new HashMap<>();
        
        // Verificar dependências aqui
        boolean dbOk = checkDatabase();
        boolean cacheOk = checkCache();
        
        if (dbOk && cacheOk) {
            response.put("status", "ready");
            return ResponseEntity.ok(response);
        } else {
            response.put("status", "not_ready");
            return ResponseEntity.status(503).body(response);
        }
    }
}
```

#### Para uma API Node.js (Express):
```javascript
const express = require('express');
const app = express();

app.get('/health', (req, res) => {
    // Liveness probe
    res.json({
        status: 'healthy',
        service: 'minha-api'
    });
});

app.get('/ready', async (req, res) => {
    try {
        // Verificar dependências
        // await database.query('SELECT 1');
        // await redis.ping();
        
        res.json({
            status: 'ready',
            dependencies: {
                database: true,
                cache: true
            }
        });
    } catch (error) {
        res.status(503).json({
            status: 'not_ready',
            error: error.message
        });
    }
});

app.listen(8080, () => {
    console.log('Server running on port 8080');
});
```

### Passo 2: Construir imagem Docker

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

# Importante: expor a porta
EXPOSE 8080

# Health check no Docker (opcional)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["npm", "start"]
```

### Passo 3: Build e push da imagem

```bash
# Build da imagem
docker build -t meuregistry/minha-api:v1.0.0 .

# Push para registry
docker push meuregistry/minha-api:v1.0.0
```

---

## 🎯 Deploy com Helm (Recomendado)

### Passo 1: Baixar os templates

```bash
# Clonar o repositório
git clone https://github.com/toolbox-tech/embracon.git
cd embracon/kubernetes-templates/helm-charts
```

### Passo 2: Configurar values.yaml

```bash
# Copiar e editar configurações
cp values.yaml my-app-values.yaml
```

```yaml
# my-app-values.yaml
# Configurações da imagem
image:
  repository: meuregistry/minha-api
  tag: "v1.0.0"
  pullPolicy: IfNotPresent

# Réplicas iniciais
replicaCount: 2

# Health Checks ATIVADOS
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/health"
      port: 8080
    initialDelaySeconds: 30  # Aguardar 30s após container iniciar
    periodSeconds: 10        # Verificar a cada 10s
    timeoutSeconds: 5        # Timeout de 5s
    failureThreshold: 3      # Falhar após 3 tentativas

  readiness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/ready"
      port: 8080
    initialDelaySeconds: 15  # Aguardar 15s
    periodSeconds: 5         # Verificar a cada 5s
    timeoutSeconds: 3        # Timeout de 3s
    failureThreshold: 3      # Falhar após 3 tentativas

# Autoscaling ATIVADO
autoscaling:
  hpa:
    enabled: true
    minReplicas: 2          # Mínimo 2 pods
    maxReplicas: 10         # Máximo 10 pods
    targetCPUUtilizationPercentage: 70    # Escalar se CPU > 70%
    targetMemoryUtilizationPercentage: 80 # Escalar se RAM > 80%

# Recursos do container
resources:
  limits:
    cpu: "1000m"      # 1 CPU
    memory: "512Mi"   # 512MB
  requests:
    cpu: "500m"       # 0.5 CPU
    memory: "256Mi"   # 256MB

# Service
service:
  type: ClusterIP
  port: 80
  targetPort: 8080
```

### Passo 3: Deploy com Helm

```bash
# Criar namespace (opcional)
kubectl create namespace minha-app

# Instalar aplicação
helm install minha-api . \
  --values my-app-values.yaml \
  --namespace minha-app

# Ver o que foi criado
helm list -n minha-app
```

### Passo 4: Verificar deployment

```bash
# Ver pods
kubectl get pods -n minha-app

# Ver serviços
kubectl get svc -n minha-app

# Ver HPA
kubectl get hpa -n minha-app

# Ver detalhes do pod
kubectl describe pod <nome-do-pod> -n minha-app
```

---

## 📄 Deploy sem Helm (YAML direto)

### Passo 1: Usar templates standalone

```bash
cd embracon/kubernetes-templates/standalone-yamls
```

### Passo 2: Editar deployment.yaml

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minha-api
  labels:
    app: minha-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: minha-api
  template:
    metadata:
      labels:
        app: minha-api
    spec:
      containers:
      - name: app
        image: meuregistry/minha-api:v1.0.0  # SUA IMAGEM AQUI
        ports:
        - containerPort: 8080
        
        # Health Checks
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        
        # Recursos
        resources:
          limits:
            cpu: "1000m"
            memory: "512Mi"
          requests:
            cpu: "500m"
            memory: "256Mi"
```

### Passo 3: Editar HPA

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: minha-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: minha-api  # MESMO NOME DO DEPLOYMENT
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Passo 4: Aplicar configurações

```bash
# Aplicar todos os YAMLs
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml

# Ou aplicar tudo de uma vez
kubectl apply -f .
```

---

## ✅ Verificando se está Funcionando

### 1. **Verificar Pods**
```bash
# Ver status dos pods
kubectl get pods

# Resultado esperado:
# NAME                        READY   STATUS    RESTARTS   AGE
# minha-api-xxx-yyy          1/1     Running   0          2m
# minha-api-xxx-zzz          1/1     Running   0          2m
```

### 2. **Verificar Health Checks**
```bash
# Ver detalhes do pod
kubectl describe pod <nome-do-pod>

# Procurar por:
# Liveness:     http-get http://:8080/health
# Readiness:    http-get http://:8080/ready
```

### 3. **Testar Health Checks manualmente**
```bash
# Port-forward para testar localmente
kubectl port-forward deployment/minha-api 8080:8080

# Em outro terminal, testar endpoints
curl http://localhost:8080/health
curl http://localhost:8080/ready
```

### 4. **Verificar HPA**
```bash
# Ver status do HPA
kubectl get hpa

# Resultado esperado:
# NAME            REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
# minha-api-hpa   Deployment/minha-api   15%/70%   2         10        2          5m

# Ver detalhes
kubectl describe hpa minha-api-hpa
```

### 5. **Verificar Logs**
```bash
# Ver logs da aplicação
kubectl logs deployment/minha-api

# Ver logs em tempo real
kubectl logs -f deployment/minha-api
```

### 6. **Simular Carga para Testar Autoscaling**
```bash
# Instalar ferramenta de teste (opcional)
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# Dentro do container, gerar carga
while true; do wget -q -O- http://minha-api/health; done
```

---

## 🚨 Troubleshooting

### ❌ **Pod não inicia**

#### Problema: Pod fica em `Pending`
```bash
# Ver por que não foi agendado
kubectl describe pod <nome-do-pod>

# Possíveis causas:
# - Recursos insuficientes no cluster
# - Imagem não encontrada
# - Pull secrets incorretos
```

#### Solução:
```bash
# Verificar nós disponíveis
kubectl get nodes

# Verificar recursos
kubectl top nodes

# Reduzir recursos solicitados
resources:
  requests:
    cpu: "100m"    # Reduzir
    memory: "128Mi" # Reduzir
```

### ❌ **Health Check falhando**

#### Problema: Pod reiniciando constantemente
```bash
# Ver logs do container
kubectl logs <nome-do-pod> --previous

# Ver eventos
kubectl get events --sort-by=.metadata.creationTimestamp
```

#### Solução:
```bash
# Aumentar timeouts
livenessProbe:
  initialDelaySeconds: 60  # Aguardar mais tempo
  timeoutSeconds: 10       # Timeout maior
  failureThreshold: 5      # Mais tentativas

# Ou desabilitar temporariamente
healthChecks:
  enabled: false
```

### ❌ **HPA não está escalando**

#### Problema: `<unknown>` nas métricas
```bash
kubectl get hpa

# NAME            REFERENCE              TARGETS     MINPODS   MAXPODS   REPLICAS
# minha-api-hpa   Deployment/minha-api   <unknown>   2         10        2
```

#### Causa: Metrics Server não instalado
```bash
# Instalar Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verificar se funcionou
kubectl top nodes
kubectl top pods
```

#### Causa: Resources não definidos
```yaml
# OBRIGATÓRIO para HPA funcionar
resources:
  requests:
    cpu: "500m"      # DEVE estar definido
    memory: "256Mi"  # DEVE estar definido
```

### ❌ **App não recebe tráfego**

#### Problema: Readiness Probe falhando
```bash
# Verificar endpoint
kubectl exec <nome-do-pod> -- curl localhost:8080/ready

# Ver detalhes do serviço
kubectl describe service minha-api
```

#### Solução:
```bash
# Simplificar readiness probe temporariamente
readinessProbe:
  httpGet:
    path: /health  # Usar mesmo endpoint do liveness
    port: 8080
```

---

## 🚀 Próximos Passos

### 1. **Adicionar Ingress**
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minha-api-ingress
spec:
  rules:
  - host: api.minhaempresa.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: minha-api
            port:
              number: 80
```

### 2. **Adicionar Monitoring**
```yaml
# ServiceMonitor para Prometheus
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: minha-api-monitor
spec:
  selector:
    matchLabels:
      app: minha-api
  endpoints:
  - port: metrics
    path: /metrics
```

### 3. **Configurar Secrets**
```bash
# Criar secret para DB
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=senha123

# Usar no deployment
env:
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: username
```

### 4. **Setup CI/CD**
```yaml
# .github/workflows/deploy.yml
name: Deploy to Kubernetes
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Deploy to K8s
      run: |
        helm upgrade --install minha-api ./helm-charts \
          --set image.tag=${{ github.sha }}
```

### 5. **Backup e Disaster Recovery**
```bash
# Fazer backup das configurações
kubectl get all -o yaml > backup.yaml

# Configurar Persistent Volumes para dados
# Implementar estratégia de backup automático
```

---

## 📖 Recursos Adicionais

### 📚 **Documentação Oficial**
- [Kubernetes Health Checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Helm Documentation](https://helm.sh/docs/)

### 🛠️ **Ferramentas Úteis**
- **kubectl**: Cliente oficial do Kubernetes
- **k9s**: Interface visual para Kubernetes
- **Lens**: Desktop app para Kubernetes
- **Stern**: Logs agregados de múltiplos pods

### 🎯 **Próximos Tópicos para Estudar**
1. **Persistent Volumes** - Para dados que sobrevivem aos pods
2. **Network Policies** - Segurança de rede
3. **RBAC** - Controle de acesso
4. **Operators** - Automação avançada
5. **Service Mesh** - Istio, Linkerd para microserviços

---

🎉 **Parabéns!** Agora você sabe como configurar Health Checks e Autoscaling no Kubernetes! 

💡 **Dica**: Comece simples e vá evoluindo. Primeiro faça funcionar, depois otimize!
