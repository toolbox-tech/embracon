# 🎯 Exemplo Prático: Deploy de API REST Completa

## 📋 Cenário
Vamos fazer o deploy de uma **API REST simples** com:
- ✅ Health checks (liveness e readiness)
- ✅ Autoscaling (HPA)
- ✅ Banco de dados PostgreSQL
- ✅ Cache Redis
- ✅ Monitoring básico

## 🏗️ Passo 1: Criar a Aplicação

### Aplicação Python (Flask)
```python
# app.py
from flask import Flask, jsonify, request
import psycopg2
import redis
import os
import time
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Configurações
DB_HOST = os.getenv('DB_HOST', 'postgres-service')
DB_NAME = os.getenv('DB_NAME', 'apidb')
DB_USER = os.getenv('DB_USER', 'apiuser')
DB_PASS = os.getenv('DB_PASS', 'apipass')

REDIS_HOST = os.getenv('REDIS_HOST', 'redis-service')
REDIS_PORT = int(os.getenv('REDIS_PORT', 6379))

# Conexões
redis_client = None
db_connection = None

def init_connections():
    global redis_client, db_connection
    
    # Redis
    try:
        redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
        redis_client.ping()
        app.logger.info("✅ Redis conectado")
    except Exception as e:
        app.logger.error(f"❌ Erro Redis: {e}")
    
    # PostgreSQL
    try:
        db_connection = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS
        )
        app.logger.info("✅ PostgreSQL conectado")
    except Exception as e:
        app.logger.error(f"❌ Erro PostgreSQL: {e}")

# Rotas da API
@app.route('/')
def home():
    return jsonify({
        "service": "API de Exemplo",
        "version": "1.0.0",
        "status": "online"
    })

@app.route('/users', methods=['GET', 'POST'])
def users():
    if request.method == 'GET':
        # Buscar usuários
        try:
            cursor = db_connection.cursor()
            cursor.execute("SELECT id, name, email FROM users")
            users = cursor.fetchall()
            return jsonify([{
                "id": user[0],
                "name": user[1], 
                "email": user[2]
            } for user in users])
        except Exception as e:
            return jsonify({"error": str(e)}), 500
    
    elif request.method == 'POST':
        # Criar usuário
        data = request.json
        try:
            cursor = db_connection.cursor()
            cursor.execute(
                "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING id",
                (data['name'], data['email'])
            )
            user_id = cursor.fetchone()[0]
            db_connection.commit()
            
            # Cache no Redis
            redis_client.setex(f"user:{user_id}", 3600, f"{data['name']}:{data['email']}")
            
            return jsonify({"id": user_id, "message": "Usuário criado"}), 201
        except Exception as e:
            return jsonify({"error": str(e)}), 500

# Health Checks
@app.route('/health')
def health():
    """Liveness Probe - Verifica se a aplicação está viva"""
    try:
        # Verificações básicas
        import psutil
        
        # CPU e memória
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        
        # Falha se recursos muito altos (simula problema interno)
        if cpu_percent > 95 or memory_percent > 95:
            return jsonify({
                "status": "unhealthy",
                "reason": "high_resource_usage",
                "cpu": cpu_percent,
                "memory": memory_percent
            }), 503
        
        return jsonify({
            "status": "healthy",
            "timestamp": time.time(),
            "resources": {
                "cpu": cpu_percent,
                "memory": memory_percent
            }
        }), 200
    except Exception as e:
        return jsonify({
            "status": "unhealthy", 
            "error": str(e)
        }), 503

@app.route('/ready')
def ready():
    """Readiness Probe - Verifica se está pronto para tráfego"""
    dependencies = {}
    all_ready = True
    
    # Verificar PostgreSQL
    try:
        cursor = db_connection.cursor()
        cursor.execute("SELECT 1")
        dependencies["postgresql"] = True
    except Exception as e:
        dependencies["postgresql"] = False
        all_ready = False
        app.logger.error(f"PostgreSQL não disponível: {e}")
    
    # Verificar Redis
    try:
        redis_client.ping()
        dependencies["redis"] = True
    except Exception as e:
        dependencies["redis"] = False
        all_ready = False
        app.logger.error(f"Redis não disponível: {e}")
    
    status_code = 200 if all_ready else 503
    status = "ready" if all_ready else "not_ready"
    
    return jsonify({
        "status": status,
        "dependencies": dependencies,
        "timestamp": time.time()
    }), status_code

@app.route('/metrics')
def metrics():
    """Endpoint para Prometheus"""
    # Métricas básicas (formato Prometheus)
    import psutil
    
    metrics = f"""
# HELP api_cpu_usage_percent CPU usage percentage
# TYPE api_cpu_usage_percent gauge
api_cpu_usage_percent {psutil.cpu_percent()}

# HELP api_memory_usage_percent Memory usage percentage  
# TYPE api_memory_usage_percent gauge
api_memory_usage_percent {psutil.virtual_memory().percent}

# HELP api_requests_total Total number of requests
# TYPE api_requests_total counter
api_requests_total 1000
"""
    return metrics, 200, {'Content-Type': 'text/plain'}

if __name__ == '__main__':
    # Inicializar conexões
    init_connections()
    
    # Criar tabela se não existir
    try:
        cursor = db_connection.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        db_connection.commit()
        app.logger.info("✅ Tabela users criada/verificada")
    except Exception as e:
        app.logger.error(f"❌ Erro ao criar tabela: {e}")
    
    # Iniciar servidor
    app.run(host='0.0.0.0', port=8080, debug=False)
```

### requirements.txt
```txt
Flask==2.3.3
psycopg2-binary==2.9.7
redis==4.6.0
psutil==5.9.5
```

### Dockerfile
```dockerfile
FROM python:3.11-slim

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    curl \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY app.py .

# Expor porta
EXPOSE 8080

# Health check no Docker
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Comando para rodar
CMD ["python", "app.py"]
```

## 🏗️ Passo 2: Build e Push da Imagem

```bash
# 1. Build da imagem
docker build -t meuregistry/api-exemplo:v1.0.0 .

# 2. Testar localmente (opcional)
docker run -p 8080:8080 meuregistry/api-exemplo:v1.0.0

# 3. Push para registry
docker push meuregistry/api-exemplo:v1.0.0
```

## 🎯 Passo 3: Configurar PostgreSQL

### postgres-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  labels:
    app: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "apidb"
        - name: POSTGRES_USER
          value: "apiuser"
        - name: POSTGRES_PASSWORD
          value: "apipass"
        
        # Health checks para PostgreSQL
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - apiuser
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - apiuser
            - -h
            - localhost
          initialDelaySeconds: 5
          periodSeconds: 5
        
        resources:
          limits:
            cpu: "1000m"
            memory: "1Gi"
          requests:
            cpu: "500m"
            memory: "512Mi"
        
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      
      volumes:
      - name: postgres-storage
        emptyDir: {}  # Para produção, usar PVC

---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  labels:
    app: postgres
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: postgres
```

## 🔴 Passo 4: Configurar Redis

### redis-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        
        # Health checks para Redis
        livenessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          tcpSocket:
            port: 6379
          initialDelaySeconds: 5
          periodSeconds: 5
        
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "250m"
            memory: "256Mi"

---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  labels:
    app: redis
spec:
  type: ClusterIP
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
```

## 🚀 Passo 5: Deploy da API com Helm

### values.yaml (customizado)
```yaml
# Configurações da aplicação
image:
  repository: meuregistry/api-exemplo
  tag: "v1.0.0"
  pullPolicy: IfNotPresent

replicaCount: 2

# Health Checks configurados
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/health"
      port: 8080
      scheme: HTTP
    initialDelaySeconds: 45  # API demora para conectar no DB
    periodSeconds: 15
    timeoutSeconds: 10
    failureThreshold: 3
  
  readiness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/ready"
      port: 8080
      scheme: HTTP
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 15       # Timeout maior para verificar DB
    failureThreshold: 5      # Mais tolerante a falhas de DB

# Autoscaling ativado
autoscaling:
  hpa:
    enabled: true
    minReplicas: 2
    maxReplicas: 8
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80
    
    behavior:
      scaleUp:
        stabilizationWindowSeconds: 60
        policies:
        - type: Percent
          value: 50
          periodSeconds: 60
      scaleDown:
        stabilizationWindowSeconds: 300
        policies:
        - type: Percent
          value: 20
          periodSeconds: 60

# Recursos ajustados para a aplicação
resources:
  limits:
    cpu: "1000m"
    memory: "512Mi"
  requests:
    cpu: "300m"       # OBRIGATÓRIO para HPA
    memory: "256Mi"   # OBRIGATÓRIO para HPA

# Service configurado
service:
  type: ClusterIP
  port: 80
  targetPort: 8080

# Variáveis de ambiente
env:
- name: DB_HOST
  value: "postgres-service"
- name: DB_NAME
  value: "apidb"
- name: DB_USER
  value: "apiuser"
- name: DB_PASS
  value: "apipass"
- name: REDIS_HOST
  value: "redis-service"
- name: REDIS_PORT
  value: "6379"

# Monitoring habilitado
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    path: /metrics
    port: http

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

## 🎯 Passo 6: Deploy Completo

```bash
# 1. Criar namespace
kubectl create namespace api-exemplo

# 2. Deploy PostgreSQL
kubectl apply -f postgres-deployment.yaml -n api-exemplo

# 3. Deploy Redis  
kubectl apply -f redis-deployment.yaml -n api-exemplo

# 4. Aguardar DBs ficarem prontos
kubectl wait --for=condition=available --timeout=300s deployment/postgres -n api-exemplo
kubectl wait --for=condition=available --timeout=300s deployment/redis -n api-exemplo

# 5. Deploy da API com Helm
helm install api-exemplo ./helm-charts \
  --values values.yaml \
  --namespace api-exemplo

# 6. Verificar se tudo subiu
kubectl get all -n api-exemplo
```

## ✅ Passo 7: Verificar e Testar

### Verificar Status
```bash
# Ver todos os recursos
kubectl get all -n api-exemplo

# Ver detalhes dos pods
kubectl get pods -n api-exemplo -o wide

# Ver HPA
kubectl get hpa -n api-exemplo

# Ver logs da API
kubectl logs -f deployment/api-exemplo -n api-exemplo
```

### Testar Health Checks
```bash
# Port forward para testar
kubectl port-forward service/api-exemplo 8080:80 -n api-exemplo

# Em outro terminal, testar endpoints
curl http://localhost:8080/health
curl http://localhost:8080/ready
curl http://localhost:8080/
```

### Testar API
```bash
# Listar usuários (deve retornar array vazio)
curl http://localhost:8080/users

# Criar usuário
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "João Silva", "email": "joao@email.com"}'

# Listar usuários novamente
curl http://localhost:8080/users
```

### Testar Autoscaling
```bash
# Verificar HPA
kubectl get hpa -n api-exemplo -w

# Gerar carga para testar escaling
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -n api-exemplo -- /bin/sh

# Dentro do container de teste
while true; do wget -q -O- http://api-exemplo/health; sleep 0.1; done
```

## 📊 Passo 8: Monitoring

### Verificar Métricas
```bash
# Ver uso de recursos
kubectl top pods -n api-exemplo
kubectl top nodes

# Ver métricas da aplicação
curl http://localhost:8080/metrics
```

### Setup Prometheus (opcional)
```bash
# Instalar Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Port forward para Grafana
kubectl port-forward service/prometheus-grafana 3000:80 -n monitoring

# Login: admin / prom-operator
```

## 🚨 Troubleshooting Comum

### API não consegue conectar no banco
```bash
# Verificar se PostgreSQL está rodando
kubectl get pods -n api-exemplo | grep postgres

# Verificar logs do PostgreSQL
kubectl logs deployment/postgres -n api-exemplo

# Testar conectividade do pod da API
kubectl exec deployment/api-exemplo -n api-exemplo -- nc -zv postgres-service 5432
```

### Health checks falhando
```bash
# Ver detalhes do health check
kubectl describe pod <nome-do-pod> -n api-exemplo | grep -A10 "Liveness\|Readiness"

# Testar manualmente
kubectl exec deployment/api-exemplo -n api-exemplo -- curl localhost:8080/health
kubectl exec deployment/api-exemplo -n api-exemplo -- curl localhost:8080/ready

# Ver logs da aplicação
kubectl logs deployment/api-exemplo -n api-exemplo --tail=50
```

### HPA não está escalando
```bash
# Verificar se Metrics Server está funcionando
kubectl top nodes
kubectl top pods -n api-exemplo

# Verificar configuração do HPA
kubectl describe hpa api-exemplo -n api-exemplo

# Verificar se resources requests estão definidos
kubectl describe deployment api-exemplo -n api-exemplo | grep -A5 "Requests"
```

## 🧹 Passo 9: Cleanup

```bash
# Remover tudo
helm uninstall api-exemplo -n api-exemplo
kubectl delete -f postgres-deployment.yaml -n api-exemplo
kubectl delete -f redis-deployment.yaml -n api-exemplo
kubectl delete namespace api-exemplo
```

## 🎓 O que você aprendeu

✅ **Health Checks funcionais** - Verificar dependências reais  
✅ **Autoscaling configurado** - HPA baseado em CPU/memória  
✅ **Aplicação completa** - API + Banco + Cache  
✅ **Deploy com Helm** - Configuração parametrizada  
✅ **Monitoring básico** - Métricas para Prometheus  
✅ **Troubleshooting** - Como identificar e resolver problemas  

## 🚀 Próximos Passos

1. **Adicionar Ingress** para acesso externo
2. **Configurar HTTPS** com certificados
3. **Implementar CI/CD** para deploy automático
4. **Adicionar testes** automatizados
5. **Configurar backup** do banco de dados
6. **Implementar logging** centralizado
7. **Adicionar alertas** para problemas

🎉 **Parabéns!** Você deployou uma aplicação completa com health checks e autoscaling funcionando!
