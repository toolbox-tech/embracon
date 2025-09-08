# Workflows: Build, Versionamento e Trivy

## 📌 Descrição
Este repositório contém workflows reutilizáveis do GitHub Actions para automatizar três etapas importantes do ciclo de vida de aplicações: 
1. **Build da imagem Docker com cache** - otimiza tempo de execução das builds;
2. **Versionamento automático** - incrementa versões baseadas em mensagens dos commits;
3. **Scan de segurança com Trivy** - analisa vulnerabilidades em imagens Docker.

## ⚙️ Workflows
### 🔹 Build com Cache (Docker)
- **Trigger**: Pull Requests para a branch `main`
- **Ações principais**:
  - Setup do ambiente
  - Build da imagem com cache
  - (Opcional) Publicação da imagem em registry
### 🧩 Cache
O cache é salvo/restaurado para otimizar o build:
- **Cache Hit** → etapas reutilizam camadas anteriores.
- **Cache Miss** → nova build, cache atualizado.

### 🔹 Versionamento Automático
- **Trigger**: Chamando como workflow reutilizável (`workflow_call`)
-Baseado em mensagens de commit:
    - fix → patch
    - feat → minor
    - BREAKING CHANGE → major
    - outros → patch (default)

- **Pré-requisito**

Habilitar o **GITHUB_TOKEN** com permissão de escrita:

Vá em: Settings → Actions → General → Workflow permissions

Habilitar o GITHUB_TOKEN com permissão de escrita:

Vá em: Settings → Actions → General → Workflow permissions

Marque: ✅ Read and write permissions

### 🔹 Trivy Scan
- **Trigger**: Pode rodar em PRs ou pushes
- Objetivo: Rodas scan de vulnerabilidades na imagem Docker

##  📸 Demo

####  ✅ Workflow executado 

- Print do npm sendo restaurado:
![Cache do npm restaured](.cache-hit-npm-restaured.png)

- Print do build do Docker com cache:
![Build do Docker com cache](.finaliz-cache-npm.png)

- Print do cache sendo exportado:
![Cache sendo exportado](.print-build-docker.png)

- Print da finalização do cache:
![Finalização do cache npm](.print-exporting-cache.png)

## 🐞 Troubleshooting

### Build com Cache
- **Forks:** PRs de forks podem não ter permissão para usar secrets → evite push para registry nesse caso; mantenha `type=gha`.
- **Cache miss constante:** verifique se `cache-from` e `cache-to` usam o mesmo tipo e escopo; cheque se o Dockerfile invalida camadas cedo (ordem das instruções!).
- **Limite de cache do GHA:** o GitHub lida com expiração/GC; `mode=max` aumenta deduplicação, mas pode crescer. Monitore tempos.
- **Dependências dentro do container:** se você instala tudo **dentro** do Docker (sem `actions/cache`), o ganho virá só do cache de layers do buildx – tá ok, mas pode somar os dois.
- **BuildKit features não cacheáveis:** mounts/secret `-mount=type=secret` não são cacheados por design.

### Versionamento
- **Token de autenticação:** usar `${{ secrets.GITHUB_TOKEN }}` no checkout.  
- **Commits fora do padrão:** sempre caem no patch.  

### Trivy
- **Excesso de vulnerabilidades:** use filtros (`--severity HIGH,CRITICAL`).  
- **Timeouts em imagens grandes:** ajuste `timeout` no step.  


