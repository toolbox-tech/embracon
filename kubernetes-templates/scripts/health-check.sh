#!/bin/bash

# Health Check Scripts para Kubernetes Probes
# Estes scripts podem ser usados em containers para implementar health checks customizados

# =============================================================================
# LIVENESS PROBE SCRIPT
# =============================================================================
# Use este script quando precisar de uma verificação customizada de "vitalidade"
# Se este script falhar, o Kubernetes irá reiniciar o container

liveness_check() {
    echo "🔍 Executando Liveness Check..."
    
    # Verifica se o processo principal está rodando (exemplo com nginx)
    if pgrep -x "nginx" > /dev/null; then
        echo "✅ Processo nginx está rodando"
    else
        echo "❌ Processo nginx não está rodando"
        exit 1
    fi
    
    # Verifica se o arquivo de lock existe (indica que a aplicação travou)
    if [ -f "/tmp/app.lock" ]; then
        echo "❌ Arquivo de lock encontrado - aplicação pode estar travada"
        exit 1
    fi
    
    # Verifica uso de memória (exemplo: falha se usar mais de 90%)
    MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    if [ "$MEMORY_USAGE" -gt 90 ]; then
        echo "❌ Uso de memória muito alto: ${MEMORY_USAGE}%"
        exit 1
    fi
    
    echo "✅ Liveness check passou - Container está vivo"
    exit 0
}

# =============================================================================
# READINESS PROBE SCRIPT
# =============================================================================
# Use este script para verificar se a aplicação está pronta para receber tráfego
# Se este script falhar, o Kubernetes para de enviar tráfego para o pod

readiness_check() {
    echo "🔍 Executando Readiness Check..."
    
    # Verifica conectividade com banco de dados
    if nc -z database-service 5432; then
        echo "✅ Conexão com banco de dados OK"
    else
        echo "❌ Não foi possível conectar com o banco de dados"
        exit 1
    fi
    
    # Verifica se API está respondendo
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✅ API está respondendo corretamente"
    else
        echo "❌ API não está respondendo (Status: $HTTP_STATUS)"
        exit 1
    fi
    
    # Verifica se todos os serviços dependentes estão disponíveis
    DEPENDENCIES=("redis-service:6379" "elasticsearch-service:9200")
    for dep in "${DEPENDENCIES[@]}"; do
        IFS=':' read -r host port <<< "$dep"
        if nc -z "$host" "$port"; then
            echo "✅ Dependência $dep está disponível"
        else
            echo "❌ Dependência $dep não está disponível"
            exit 1
        fi
    done
    
    echo "✅ Readiness check passou - Pod pronto para receber tráfego"
    exit 0
}

# =============================================================================
# STARTUP PROBE SCRIPT
# =============================================================================
# Use este script para aplicações que demoram muito para inicializar
# Protege o container durante a inicialização

startup_check() {
    echo "🔍 Executando Startup Check..."
    
    # Verifica se arquivo de inicialização foi criado
    if [ -f "/tmp/app-initialized" ]; then
        echo "✅ Aplicação já foi inicializada"
        exit 0
    fi
    
    # Verifica se processo de inicialização está rodando
    if pgrep -f "initialization" > /dev/null; then
        echo "⏳ Processo de inicialização ainda rodando..."
        exit 1
    fi
    
    # Verifica se aplicação consegue responder requisições básicas
    if curl -s -f http://localhost:8080/startup > /dev/null; then
        echo "✅ Aplicação respondeu ao startup check"
        touch /tmp/app-initialized
        exit 0
    else
        echo "❌ Aplicação ainda não está pronta"
        exit 1
    fi
}

# =============================================================================
# FUNÇÕES AUXILIARES
# =============================================================================

# Função para verificar conectividade de rede
check_network_connectivity() {
    local host=$1
    local port=$2
    local timeout=${3:-5}
    
    if timeout "$timeout" bash -c "</dev/tcp/$host/$port"; then
        return 0
    else
        return 1
    fi
}

# Função para verificar uso de recursos
check_resource_usage() {
    local cpu_threshold=${1:-80}
    local memory_threshold=${2:-80}
    
    # CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    if (( $(echo "$CPU_USAGE > $cpu_threshold" | bc -l) )); then
        echo "❌ CPU usage too high: ${CPU_USAGE}%"
        return 1
    fi
    
    # Memory usage
    MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    if [ "$MEMORY_USAGE" -gt "$memory_threshold" ]; then
        echo "❌ Memory usage too high: ${MEMORY_USAGE}%"
        return 1
    fi
    
    return 0
}

# Função para log estruturado
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\"}"
}

# =============================================================================
# EXECUÇÃO PRINCIPAL
# =============================================================================

case "$1" in
    "liveness")
        liveness_check
        ;;
    "readiness")
        readiness_check
        ;;
    "startup")
        startup_check
        ;;
    *)
        echo "Uso: $0 {liveness|readiness|startup}"
        echo ""
        echo "Exemplos de uso no Kubernetes:"
        echo ""
        echo "livenessProbe:"
        echo "  exec:"
        echo "    command: [\"/health-check.sh\", \"liveness\"]"
        echo ""
        echo "readinessProbe:"
        echo "  exec:"
        echo "    command: [\"/health-check.sh\", \"readiness\"]"
        echo ""
        echo "startupProbe:"
        echo "  exec:"
        echo "    command: [\"/health-check.sh\", \"startup\"]"
        exit 1
        ;;
esac
