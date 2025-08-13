# 🚀 Comandos Essenciais - Cheat Sheet

## 📋 Comandos Kubectl Básicos

### 🔍 **Visualização e Status**
```bash
# Ver todos os recursos
kubectl get all

# Ver pods
kubectl get pods
kubectl get pods -o wide  # Mais detalhes
kubectl get pods -w       # Watch mode (tempo real)

# Ver serviços
kubectl get services
kubectl get svc           # Forma curta

# Ver deployments
kubectl get deployments
kubectl get deploy        # Forma curta

# Ver nós do cluster
kubectl get nodes

# Ver namespaces
kubectl get namespaces
kubectl get ns            # Forma curta
```

### 📊 **Detalhes e Logs**
```bash
# Detalhes de um recurso
kubectl describe pod <nome-do-pod>
kubectl describe service <nome-do-service>
kubectl describe deployment <nome-do-deployment>

# Logs da aplicação
kubectl logs <nome-do-pod>
kubectl logs -f <nome-do-pod>              # Follow (tempo real)
kubectl logs --tail=50 <nome-do-pod>       # Últimas 50 linhas
kubectl logs --since=1h <nome-do-pod>      # Última hora

# Logs de deployment
kubectl logs deployment/<nome-do-deployment>
```

### 🔧 **Execução e Debug**
```bash
# Executar comando em pod
kubectl exec <nome-do-pod> -- <comando>
kubectl exec -it <nome-do-pod> -- /bin/bash  # Shell interativo

# Port forwarding (acesso local)
kubectl port-forward pod/<nome-do-pod> 8080:8080
kubectl port-forward service/<nome-do-service> 8080:80

# Copiar arquivos
kubectl cp <arquivo-local> <nome-do-pod>:/caminho/destino
kubectl cp <nome-do-pod>:/caminho/origem <arquivo-local>
```

### 🎯 **Aplicação e Gestão**
```bash
# Aplicar configuração
kubectl apply -f arquivo.yaml
kubectl apply -f pasta/
kubectl apply -f https://url-do-arquivo.yaml

# Deletar recursos
kubectl delete -f arquivo.yaml
kubectl delete pod <nome-do-pod>
kubectl delete deployment <nome-do-deployment>

# Escalar deployment
kubectl scale deployment <nome> --replicas=5

# Restart de deployment
kubectl rollout restart deployment/<nome>

# Ver histórico de rollouts
kubectl rollout history deployment/<nome>

# Rollback para versão anterior
kubectl rollout undo deployment/<nome>
```

## 🎪 **Comandos Helm**

### 📦 **Gestão de Charts**
```bash
# Instalar chart
helm install <nome-release> <caminho-chart>
helm install minha-app ./helm-chart

# Instalar com values customizados
helm install minha-app ./helm-chart -f values.yaml
helm install minha-app ./helm-chart --set image.tag=v2.0.0

# Listar releases
helm list
helm list -A  # Todos os namespaces

# Ver status
helm status <nome-release>

# Upgrade
helm upgrade <nome-release> <caminho-chart>
helm upgrade minha-app ./helm-chart --set replicas=5

# Desinstalar
helm uninstall <nome-release>
```

### 🔍 **Debug e Dry-run**
```bash
# Simular instalação (não aplica)
helm install minha-app ./helm-chart --dry-run --debug

# Ver templates renderizados
helm template minha-app ./helm-chart

# Ver valores atuais
helm get values <nome-release>

# Ver manifesto aplicado
helm get manifest <nome-release>

# Histórico de releases
helm history <nome-release>

# Rollback
helm rollback <nome-release> <revisao>
```

## 🏥 **Health Checks - Comandos de Debug**

### 🔍 **Verificar Health Checks**
```bash
# Ver configuração dos probes
kubectl describe pod <nome-do-pod> | grep -A5 "Liveness\|Readiness\|Startup"

# Testar endpoint manualmente
kubectl exec <nome-do-pod> -- curl localhost:8080/health
kubectl exec <nome-do-pod> -- curl localhost:8080/ready

# Ver eventos relacionados a health checks
kubectl get events --field-selector involvedObject.name=<nome-do-pod>

# Ver restarts por falha de health check
kubectl get pods -o wide
```

### 🚨 **Quando Health Check está falhando**
```bash
# Ver logs do container anterior (antes do restart)
kubectl logs <nome-do-pod> --previous

# Ver últimos eventos do cluster
kubectl get events --sort-by=.metadata.creationTimestamp

# Executar health check manualmente
kubectl exec <nome-do-pod> -- /health-check.sh liveness
kubectl exec <nome-do-pod> -- /health-check.sh readiness

# Port forward para testar local
kubectl port-forward <nome-do-pod> 8080:8080
curl http://localhost:8080/health
```

## 📈 **Autoscaling - Comandos HPA/VPA**

### 🔄 **HPA (Horizontal Pod Autoscaler)**
```bash
# Ver status do HPA
kubectl get hpa
kubectl get hpa -w  # Watch mode

# Detalhes do HPA
kubectl describe hpa <nome-do-hpa>

# Ver métricas dos pods
kubectl top pods
kubectl top nodes

# Criar HPA via comando
kubectl autoscale deployment <nome> --cpu-percent=70 --min=2 --max=10

# Deletar HPA
kubectl delete hpa <nome-do-hpa>
```

### 📊 **VPA (Vertical Pod Autoscaler)**
```bash
# Ver recomendações do VPA
kubectl describe vpa <nome-do-vpa>

# Ver histórico de recomendações
kubectl get vpa <nome-do-vpa> -o yaml

# Aplicar recomendações manualmente
kubectl patch deployment <nome> -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"requests":{"cpu":"500m","memory":"512Mi"}}}]}}}}'
```

## 🔧 **Troubleshooting Essencial**

### 🚨 **Pod não inicia**
```bash
# Ver por que pod não foi agendado
kubectl describe pod <nome-do-pod>

# Ver recursos disponíveis
kubectl top nodes
kubectl describe nodes

# Ver eventos do namespace
kubectl get events

# Verificar imagem
kubectl describe pod <nome-do-pod> | grep Image

# Verificar pull secrets
kubectl get secrets
```

### 🔄 **Pod reiniciando constantemente**
```bash
# Ver quantos restarts
kubectl get pods

# Ver logs do container anterior
kubectl logs <nome-do-pod> --previous

# Ver configuração de health checks
kubectl describe pod <nome-do-pod> | grep -A10 "Liveness\|Readiness"

# Verificar recursos de CPU/memória
kubectl top pod <nome-do-pod>
```

### 🌐 **Problemas de rede/conectividade**
```bash
# Testar conectividade entre pods
kubectl exec <pod1> -- ping <ip-do-pod2>
kubectl exec <pod1> -- nslookup <nome-do-service>

# Ver endpoints do service
kubectl get endpoints

# Testar service
kubectl exec <nome-do-pod> -- curl <nome-do-service>:<porta>

# Ver iptables (avançado)
kubectl exec <nome-do-pod> -- iptables -L
```

### 📊 **Problemas de recursos**
```bash
# Ver uso atual de recursos
kubectl top pods
kubectl top nodes

# Ver limites configurados
kubectl describe pod <nome-do-pod> | grep -A5 "Limits\|Requests"

# Ver pods que foram "evicted"
kubectl get pods | grep Evicted

# Limpar pods evicted
kubectl get pods | grep Evicted | awk '{print $1}' | xargs kubectl delete pod
```

## 💾 **Backup e Restore**

### 📦 **Backup de configurações**
```bash
# Backup de um namespace inteiro
kubectl get all -n <namespace> -o yaml > backup-namespace.yaml

# Backup de recursos específicos
kubectl get deployment <nome> -o yaml > backup-deployment.yaml
kubectl get configmap <nome> -o yaml > backup-configmap.yaml
kubectl get secret <nome> -o yaml > backup-secret.yaml

# Backup de persistent volumes
kubectl get pv -o yaml > backup-pv.yaml
kubectl get pvc -o yaml > backup-pvc.yaml
```

### 🔄 **Restore**
```bash
# Restaurar recursos
kubectl apply -f backup-namespace.yaml

# Restaurar com namespace específico
kubectl apply -f backup.yaml -n <novo-namespace>
```

## 🔑 **Comandos de Segurança**

### 🛡️ **Secrets e ConfigMaps**
```bash
# Criar secret genérico
kubectl create secret generic <nome> \
  --from-literal=usuario=admin \
  --from-literal=senha=123456

# Criar secret para registry
kubectl create secret docker-registry <nome> \
  --docker-server=<servidor> \
  --docker-username=<usuario> \
  --docker-password=<senha>

# Criar configmap
kubectl create configmap <nome> \
  --from-literal=config.property=valor \
  --from-file=config.yaml

# Ver secret decodificado
kubectl get secret <nome> -o yaml | grep <chave> | awk '{print $2}' | base64 -d
```

### 👥 **RBAC**
```bash
# Ver permissões atuais
kubectl auth can-i <verbo> <recurso>
kubectl auth can-i create pods
kubectl auth can-i get secrets --as=system:serviceaccount:default:mysa

# Ver roles e bindings
kubectl get roles
kubectl get rolebindings
kubectl get clusterroles
kubectl get clusterrolebindings
```

## 🎯 **Comandos por Cenário**

### 🚀 **Deploy de nova versão**
```bash
# 1. Build e push da imagem
docker build -t meuregistry/app:v2.0.0 .
docker push meuregistry/app:v2.0.0

# 2. Update via kubectl
kubectl set image deployment/minha-app app=meuregistry/app:v2.0.0

# 3. Ou via Helm
helm upgrade minha-app ./helm-chart --set image.tag=v2.0.0

# 4. Verificar rollout
kubectl rollout status deployment/minha-app

# 5. Se deu erro, fazer rollback
kubectl rollout undo deployment/minha-app
```

### 🔍 **Debug de aplicação lenta**
```bash
# 1. Ver uso de recursos
kubectl top pods

# 2. Ver health checks
kubectl describe pod <nome> | grep -A5 "Liveness\|Readiness"

# 3. Ver logs
kubectl logs -f <nome-do-pod>

# 4. Entrar no container
kubectl exec -it <nome-do-pod> -- /bin/bash

# 5. Verificar processos
kubectl exec <nome-do-pod> -- ps aux
kubectl exec <nome-do-pod> -- top
```

### 📊 **Setup de monitoring**
```bash
# 1. Verificar se métricas estão funcionando
kubectl top nodes
kubectl top pods

# 2. Ver HPA
kubectl get hpa

# 3. Instalar Prometheus (exemplo)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack

# 4. Port forward para Grafana
kubectl port-forward service/prometheus-grafana 3000:80
```

## 📱 **Aliases Úteis**

Adicione no seu `.bashrc` ou `.zshrc`:

```bash
# Aliases kubectl
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployment'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kpf='kubectl port-forward'

# Aliases helm
alias h='helm'
alias hls='helm list'
alias hst='helm status'
alias hup='helm upgrade'
alias hin='helm install'
alias hun='helm uninstall'

# Navegação por namespace
alias kn='kubectl config set-context --current --namespace'
```

## 🔧 **Configuração de Context**

```bash
# Ver contexts disponíveis
kubectl config get-contexts

# Mudar context
kubectl config use-context <nome-do-context>

# Ver configuração atual
kubectl config current-context

# Mudar namespace padrão
kubectl config set-context --current --namespace=<namespace>

# Ver configuração completa
kubectl config view
```

---

## 💡 **Dicas Essenciais**

1. **Sempre use namespaces** para organizar recursos
2. **Configure resource requests/limits** para HPA funcionar
3. **Use labels consistentes** para facilitar seleção
4. **Monitore logs regularmente** para detectar problemas
5. **Faça backup das configurações** antes de mudanças importantes
6. **Teste health checks localmente** antes de aplicar
7. **Use dry-run** para validar YAMLs antes de aplicar
8. **Monitore métricas** para otimizar recursos

---

🎯 **Salve este cheat sheet** para consulta rápida durante troubleshooting!
