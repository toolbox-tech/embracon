# 📚 Exemplos de Implementação - Kubernetes Templates

Esta pasta contém exemplos práticos e detalhados de como implementar health checks e configurações de autoscaling para diferentes tipos de aplicações.

## 📋 Conteúdo

### 🔧 [health-implementations.md](./health-implementations.md)
Implementações completas de health checks para diferentes linguagens de programação:
- **Python** (Flask/FastAPI) - Exemplos assíncronos e síncronos
- **Java** (Spring Boot) - Utilizando Spring Actuator
- **Node.js** (Express) - Health checks para aplicações JavaScript
- **C#** (.NET Core) - Implementação usando ASP.NET Core

### ⚙️ [configuration-scenarios.md](./configuration-scenarios.md)
Configurações específicas por tipo de aplicação:
- **Aplicação Web Simples** - Frontend/SPA
- **API REST com Banco** - Backend com dependências
- **Microserviços Complexos** - Múltiplas dependências
- **Aplicações Legacy** - Inicialização lenta
- **Streaming/Processamento** - Kafka, batch jobs
- **Bancos de Dados** - PostgreSQL, MySQL
- **Cache** - Redis, Memcached

## 🎯 Como Usar os Exemplos

### 1. Escolha o Cenário Apropriado
Identifique qual tipo de aplicação você está deployando:

```bash
# Para uma API REST simples
cp configuration-scenarios.md api-config.yaml

# Para uma aplicação com inicialização lenta
cp configuration-scenarios.md legacy-config.yaml
```

### 2. Implemente os Health Checks
Escolha a implementação correspondente à sua linguagem:

```bash
# Para Python Flask
cp health-implementations.md app/health.py

# Para Java Spring Boot
cp health-implementations.md src/main/java/HealthController.java
```

### 3. Adapte ao Seu Helm Chart
Use as configurações nos seus values.yaml:

```yaml
# values.yaml
healthChecks:
  enabled: true
  liveness:
    # Copie configuração do cenário apropriado
  readiness:
    # Copie configuração do cenário apropriado
```

## 🚀 Cenários Comuns

### 🔄 API REST Padrão
```yaml
# Configuração recomendada para APIs REST
healthChecks:
  liveness:
    type: "httpGet"
    httpGet:
      path: "/health"
      port: 8080
    initialDelaySeconds: 30
    periodSeconds: 10
  
  readiness:
    type: "httpGet"
    httpGet:
      path: "/ready"
      port: 8080
    initialDelaySeconds: 15
    periodSeconds: 5
```

### 📊 Aplicação com Banco de Dados
```yaml
# Configuração para apps que dependem de DB
healthChecks:
  readiness:
    type: "exec"
    exec:
      command: ["/health-check.sh", "readiness"]
    timeoutSeconds: 15  # Mais tempo para verificar DB
    failureThreshold: 5 # Mais tolerante
```

### ⚡ Aplicação de Alto Throughput
```yaml
# Configuração para apps com muito tráfego
autoscaling:
  hpa:
    enabled: true
    minReplicas: 3
    maxReplicas: 50
    targetCPUUtilizationPercentage: 60
    behavior:
      scaleUp:
        policies:
        - type: Pods
          value: 5
          periodSeconds: 30
```

## 🛠️ Customização

### Modificando Timeouts
```yaml
# Para aplicações mais lentas
healthChecks:
  liveness:
    timeoutSeconds: 10      # Aumentar timeout
    failureThreshold: 5     # Mais tentativas
    periodSeconds: 15       # Verificar menos frequente
```

### Adicionando Métricas Customizadas
```yaml
# Para HPA com métricas customizadas
autoscaling:
  hpa:
    customMetrics:
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: "1k"
```

### Health Checks Condicionais
```yaml
# No template Helm - health check condicional
{{- if .Values.database.enabled }}
readinessProbe:
  exec:
    command: ["/check-db.sh"]
{{- else }}
readinessProbe:
  httpGet:
    path: /ready
{{- end }}
```

## 📈 Monitoramento

### Métricas Importantes
- **Liveness Failures**: Quantos containers foram reiniciados
- **Readiness Failures**: Quanto tempo pods ficaram fora do LB
- **Startup Time**: Tempo médio de inicialização
- **Resource Usage**: CPU/Memory antes dos health checks falharem

### Alertas Recomendados
```yaml
# Exemplo de alertas Prometheus
- alert: HighLivenessFailures
  expr: rate(container_restart_total[5m]) > 0.1
  for: 2m
  annotations:
    summary: "High restart rate for {{ $labels.pod }}"

- alert: ReadinessFailures
  expr: kube_pod_status_ready{condition="false"} == 1
  for: 1m
  annotations:
    summary: "Pod {{ $labels.pod }} not ready"
```

## 🔍 Troubleshooting

### Health Check Falhando
1. **Verifique logs**: `kubectl logs <pod-name>`
2. **Teste manualmente**: `kubectl exec <pod> -- curl localhost:8080/health`
3. **Ajuste timeouts**: Aumente `timeoutSeconds` e `failureThreshold`
4. **Verifique dependências**: DB, Redis, APIs externas

### HPA Não Escalando
1. **Metrics Server**: `kubectl top nodes`
2. **Resource requests**: Definir requests de CPU/Memory
3. **Target percentage**: Ajustar threshold de CPU
4. **Behavior policies**: Verificar políticas de scale up/down

### VPA Não Aplicando
1. **Admission Controller**: Verificar se VPA está instalado
2. **Update Mode**: Usar "Auto" para aplicar automaticamente
3. **Resource limits**: Verificar se não há conflito com limits fixos

## 📝 Exemplos Adicionais

Para mais exemplos específicos, consulte:
- [../scripts/health-check.sh](../scripts/health-check.sh) - Scripts de health check
- [../standalone-yamls/](../standalone-yamls/) - YAMLs prontos para uso
- [../helm-charts/templates/](../helm-charts/templates/) - Templates Helm completos
