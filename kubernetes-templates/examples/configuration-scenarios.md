# 🎯 Configurações de Health Checks por Cenário

## 📊 Cenário 1: Aplicação Web Simples (Frontend)

```yaml
# Para SPAs, sites estáticos, ou aplicações frontend simples
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/"
      port: 80
      scheme: HTTP
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3

  readiness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/"
      port: 80
      scheme: HTTP
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 3
    failureThreshold: 3

  startup:
    enabled: false  # Não necessário para apps simples
```

## 🔐 Cenário 2: API REST com Banco de Dados

```yaml
# Para APIs que dependem de banco de dados
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/health"
      port: 8080
      scheme: HTTP
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3

  readiness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/ready"  # Verifica DB e dependências
      port: 8080
      scheme: HTTP
    initialDelaySeconds: 15
    periodSeconds: 5
    timeoutSeconds: 10  # Timeout maior para verificação de DB
    failureThreshold: 5  # Mais tolerante a falhas temporárias

  startup:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/startup"
      port: 8080
      scheme: HTTP
    initialDelaySeconds: 20
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 30  # 5 minutos para inicializar
```

## 🔄 Cenário 3: Microserviço com Múltiplas Dependências

```yaml
# Para microserviços complexos com Redis, DB, APIs externas
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "exec"
    exec:
      command:
        - "/health-check.sh"
        - "liveness"
    initialDelaySeconds: 45
    periodSeconds: 15
    timeoutSeconds: 10
    failureThreshold: 3

  readiness:
    enabled: true
    type: "exec"
    exec:
      command:
        - "/health-check.sh"
        - "readiness"
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 15
    failureThreshold: 5

  startup:
    enabled: true
    type: "exec"
    exec:
      command:
        - "/health-check.sh"
        - "startup"
    initialDelaySeconds: 30
    periodSeconds: 15
    timeoutSeconds: 10
    failureThreshold: 40  # 10 minutos para inicializar
```

## 🔧 Cenário 4: Aplicação Legacy com Inicialização Lenta

```yaml
# Para aplicações que demoram muito para inicializar (ex: Java EAR)
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "tcpSocket"
    tcpSocket:
      port: 8080
    initialDelaySeconds: 180  # 3 minutos após inicialização
    periodSeconds: 30
    timeoutSeconds: 10
    failureThreshold: 3

  readiness:
    enabled: true
    type: "httpGet"
    httpGet:
      path: "/actuator/health"
      port: 8080
      scheme: HTTP
    initialDelaySeconds: 120  # 2 minutos
    periodSeconds: 15
    timeoutSeconds: 10
    failureThreshold: 10

  startup:
    enabled: true
    type: "tcpSocket"
    tcpSocket:
      port: 8080
    initialDelaySeconds: 60   # 1 minuto
    periodSeconds: 30
    timeoutSeconds: 10
    failureThreshold: 20      # 10 minutos total
```

## 📊 Cenário 5: Aplicação de Streaming/Processamento

```yaml
# Para aplicações Kafka, streaming, processamento batch
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "exec"
    exec:
      command:
        - "/bin/bash"
        - "-c"
        - "ps aux | grep -v grep | grep java && echo 'Process alive'"
    initialDelaySeconds: 60
    periodSeconds: 30
    timeoutSeconds: 5
    failureThreshold: 3

  readiness:
    enabled: true
    type: "exec"
    exec:
      command:
        - "/bin/bash"
        - "-c"
        - "nc -z kafka-broker 9092 && echo 'Kafka available'"
    initialDelaySeconds: 30
    periodSeconds: 15
    timeoutSeconds: 10
    failureThreshold: 5

  startup:
    enabled: true
    type: "exec"
    exec:
      command:
        - "/health-check.sh"
        - "startup"
    initialDelaySeconds: 45
    periodSeconds: 20
    timeoutSeconds: 15
    failureThreshold: 15  # 5 minutos
```

## 🗄️ Cenário 6: Banco de Dados (PostgreSQL/MySQL)

```yaml
# Para containers de banco de dados
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "exec"
    exec:
      command:
        - "pg_isready"
        - "-U"
        - "postgres"
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 6

  readiness:
    enabled: true
    type: "exec"
    exec:
      command:
        - "pg_isready"
        - "-U"
        - "postgres"
        - "-h"
        - "localhost"
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 3
    failureThreshold: 3

  startup:
    enabled: true
    type: "exec"
    exec:
      command:
        - "pg_isready"
        - "-U"
        - "postgres"
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 30
```

## ⚡ Cenário 7: Cache Redis

```yaml
# Para containers Redis
healthChecks:
  enabled: true
  
  liveness:
    enabled: true
    type: "exec"
    exec:
      command:
        - "redis-cli"
        - "ping"
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3

  readiness:
    enabled: true
    type: "tcpSocket"
    tcpSocket:
      port: 6379
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 3
    failureThreshold: 3

  startup:
    enabled: false  # Redis inicializa rapidamente
```

# 🏆 Melhores Práticas por Tipo de Health Check

## Liveness Probe
- **Objetivo**: Detectar quando reiniciar o container
- **Verificações**: Estado interno da aplicação, deadlocks, vazamentos de memória
- **Evitar**: Verificações de dependências externas
- **Timeout**: Mais curto (5-10s)
- **Frequência**: Menos frequente (10-30s)

## Readiness Probe
- **Objetivo**: Controlar roteamento de tráfego
- **Verificações**: Todas as dependências críticas (DB, APIs, cache)
- **Incluir**: Verificações de conectividade e funcionalidade
- **Timeout**: Pode ser maior (10-15s)
- **Frequência**: Mais frequente (5-10s)

## Startup Probe
- **Objetivo**: Proteger durante inicialização
- **Verificações**: Estado básico de inicialização
- **Usar quando**: Aplicação demora mais que 10s para inicializar
- **Timeout**: Pode ser bem maior
- **Frequência**: Menos frequente durante startup

# 📈 Configurações de Autoscaling Recomendadas

## HPA (Horizontal Pod Autoscaler)

### Aplicação Web Típica
```yaml
autoscaling:
  hpa:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
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
          value: 10
          periodSeconds: 60
```

### API com Alto Throughput
```yaml
autoscaling:
  hpa:
    enabled: true
    minReplicas: 3
    maxReplicas: 50
    targetCPUUtilizationPercentage: 60
    behavior:
      scaleUp:
        stabilizationWindowSeconds: 30
        policies:
        - type: Pods
          value: 5
          periodSeconds: 30
        - type: Percent
          value: 100
          periodSeconds: 30
        selectPolicy: Max
      scaleDown:
        stabilizationWindowSeconds: 600
        policies:
        - type: Percent
          value: 5
          periodSeconds: 60
```

### Processamento Batch
```yaml
autoscaling:
  hpa:
    enabled: true
    minReplicas: 1
    maxReplicas: 20
    targetCPUUtilizationPercentage: 80
    behavior:
      scaleUp:
        stabilizationWindowSeconds: 120
        policies:
        - type: Percent
          value: 100
          periodSeconds: 120
      scaleDown:
        stabilizationWindowSeconds: 900
        policies:
        - type: Percent
          value: 20
          periodSeconds: 120
```

## VPA (Vertical Pod Autoscaler)

### Aplicação com Uso Variável de Recursos
```yaml
autoscaling:
  vpa:
    enabled: true
    updateMode: "Auto"
    resourcePolicy:
      containerPolicies:
      - containerName: app
        maxAllowed:
          cpu: "4000m"
          memory: "8Gi"
        minAllowed:
          cpu: "100m"
          memory: "128Mi"
        controlledResources: ["cpu", "memory"]
```

### Aplicação Crítica (Recomendação apenas)
```yaml
autoscaling:
  vpa:
    enabled: true
    updateMode: "Off"  # Apenas recomendações
    resourcePolicy:
      containerPolicies:
      - containerName: app
        maxAllowed:
          cpu: "2000m"
          memory: "4Gi"
        minAllowed:
          cpu: "500m"
          memory: "512Mi"
        controlledResources: ["cpu", "memory"]
```
