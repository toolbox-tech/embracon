# Guia Prático de Espelhamento de Imagens Docker

Este guia oferece exemplos práticos e orientações detalhadas para o uso dos scripts de espelhamento de imagens Docker do Docker Hub para o Azure Container Registry (ACR).

## 📝 Índice

1. [Preparação do Ambiente](#preparação-do-ambiente)
2. [Configuração das Imagens](#configuração-das-imagens)
3. [Escaneamento de Vulnerabilidades](#escaneamento-de-vulnerabilidades)
4. [Espelhamento para o ACR](#espelhamento-para-o-acr)
5. [Solução de Problemas](#solução-de-problemas)
6. [Cenários de Uso](#cenários-de-uso)

## 🛠 Preparação do Ambiente

### Pré-requisitos:

1. **Docker CLI instalado:**
   ```powershell
   # Verificar se o Docker está instalado
   docker --version
   ```

2. **Azure CLI instalado e configurado:**
   ```powershell
   # Instalar Azure CLI (caso ainda não tenha)
   winget install -e --id Microsoft.AzureCLI
   
   # Login no Azure
   az login
   ```

3. **Trivy para escaneamento de vulnerabilidades:**
   ```powershell
   # Instalar Trivy usando Chocolatey
   choco install trivy

   # OU usando winget
   winget install -e --id Aquasecurity.Trivy
   ```

4. **PowerShell 7+ (pwsh):**
   ```powershell
   # Verificar versão do PowerShell
   $PSVersionTable.PSVersion

   # Instalar/atualizar PowerShell se necessário
   winget install -e --id Microsoft.PowerShell
   ```

### Estrutura dos Diretórios:

Crie uma estrutura organizada para seus scripts e configurações:

```
scripts/
├── mirror-dockerhub-to-acr.ps1
├── scan-docker-vulnerabilities.ps1
├── docker-images.json
└── README.md
```

## 📋 Configuração das Imagens

O arquivo `docker-images.json` contém a lista de imagens a serem espelhadas e/ou analisadas.

### Exemplo de Arquivo de Configuração:

```json
{
    "images": [
        {
            "repository": "maven",
            "tag": "3.6.3-openjdk-17-slim",
            "description": "Maven com OpenJDK 17 para builds Java",
            "targetRepository": "maven"
        },
        {
            "repository": "openjdk",
            "tag": "21-slim",
            "description": "OpenJDK 21 versão slim",
            "targetRepository": "java"
        }
    ]
}
```

### Como adicionar novas imagens:

1. Identifique a imagem que você precisa espelhar
2. Determine a tag específica que você quer usar
3. Adicione ao arquivo JSON seguindo o formato acima
4. Se precisar agrupar imagens, use o campo `targetRepository`

## 🔍 Escaneamento de Vulnerabilidades

Antes de espelhar imagens, é importante verificar se elas possuem vulnerabilidades conhecidas.

### Exemplo básico:

```powershell
./scan-docker-vulnerabilities.ps1 -ConfigFile ./docker-images.json
```

### Exemplo com parâmetros adicionais:

```powershell
./scan-docker-vulnerabilities.ps1 -ConfigFile ./docker-images.json -OutputFile ./relatorio-vulnerabilidades.md -OutputFormat Markdown -MinimumSeverity HIGH
```

### Interpretação dos resultados:

O relatório gerado incluirá:
- **Sumário das vulnerabilidades** por imagem
- **Vulnerabilidades críticas** que devem ser resolvidas imediatamente
- **Recomendações** para mitigar os problemas encontrados

## 🔄 Espelhamento para o ACR

Depois de validar as imagens, você pode espelhá-las para o seu Azure Container Registry.

### Exemplo básico:

```powershell
./mirror-dockerhub-to-acr.ps1 -ConfigFile ./docker-images.json -AcrName meuacr -AcrResourceGroup meu-grupo-recursos
```

### Exemplo com parâmetros adicionais:

```powershell
./mirror-dockerhub-to-acr.ps1 -ConfigFile ./docker-images.json -AcrName meuacr -AcrResourceGroup meu-grupo-recursos -TargetRepository "images/docker-hub" -SubscriptionId "00000000-0000-0000-0000-000000000000"
```

### Verificando as imagens espelhadas:

Após o espelhamento, você pode verificar se as imagens foram corretamente enviadas para o ACR:

```powershell
# Listar os repositórios no ACR
az acr repository list --name meuacr --output table

# Listar as tags de um repositório específico
az acr repository show-tags --name meuacr --repository mirrors/maven --output table
```

## ⚠️ Solução de Problemas

### Problemas comuns e soluções:

1. **Erro de autenticação no ACR:**
   ```powershell
   # Verificar se você está autenticado
   az account show
   
   # Autenticar novamente se necessário
   az login
   
   # Verificar se você tem acesso ao ACR
   az acr login --name meuacr
   ```

2. **Limites de Rate Limit do Docker Hub:**
   ```powershell
   # Verificar o status atual de rate limit
   docker pull --quiet hello-world
   docker pull --quiet hello-world
   
   # Se encontrar limites, você pode autenticar-se no Docker Hub
   docker login
   ```

3. **Erros no escaneamento de vulnerabilidades:**
   ```powershell
   # Atualizar o Trivy e suas bases de dados
   trivy --download-db-only
   ```

4. **Imagens muito grandes:**
   ```powershell
   # Verificar espaço disponível no disco
   Get-PSDrive -PSProvider FileSystem
   
   # Limpar imagens não utilizadas
   docker system prune -a
   ```

## 🚀 Cenários de Uso

### 1. Automatização em Pipeline de CI/CD (Azure DevOps):

```yaml
# azure-pipelines.yml
steps:
- task: PowerShell@2
  displayName: 'Escanear Vulnerabilidades'
  inputs:
    filePath: './scripts/scan-docker-vulnerabilities.ps1'
    arguments: '-ConfigFile ./scripts/docker-images.json -OutputFile $(Build.ArtifactStagingDirectory)/vulnerabilidades.md -MinimumSeverity HIGH'

- task: PowerShell@2
  displayName: 'Espelhar Imagens para ACR'
  inputs:
    filePath: './scripts/mirror-dockerhub-to-acr.ps1'
    arguments: '-ConfigFile ./scripts/docker-images.json -AcrName $(acrName) -AcrResourceGroup $(acrResourceGroup)'

- task: PublishBuildArtifacts@1
  displayName: 'Publicar Relatório de Vulnerabilidades'
  inputs:
    pathtoPublish: '$(Build.ArtifactStagingDirectory)'
    artifactName: 'relatorios'
```

### 2. Atualização Periódica de Imagens:

Agende uma execução dos scripts periodicamente para manter suas imagens atualizadas:

```powershell
# Crie uma tarefa agendada no Windows para executar semanalmente
$action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument '-File "C:\caminho\para\mirror-dockerhub-to-acr.ps1" -ConfigFile "C:\caminho\para\docker-images.json" -AcrName meuacr -AcrResourceGroup meu-grupo-recursos'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At "3:00AM"
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AtualizarImagensDocker" -Description "Atualiza imagens Docker no ACR"
```

### 3. Uso em Ambientes de Desenvolvimento Local:

Crie um script simplificado para desenvolvedores usarem localmente:

```powershell
# setup-dev-environment.ps1
param(
    [string]$AcrName = "meuacr",
    [string]$ResourceGroup = "meu-grupo-recursos"
)

# Autenticar no Azure
Write-Host "Autenticando no Azure..."
az login --use-device-code

# Autenticar no ACR
Write-Host "Autenticando no ACR $AcrName..."
az acr login --name $AcrName

# Baixar imagens necessárias para desenvolvimento
Write-Host "Baixando imagens para desenvolvimento local..."
$imagens = @(
    "$AcrName.azurecr.io/mirrors/maven:3.6.3-openjdk-17-slim",
    "$AcrName.azurecr.io/mirrors/node:18-alpine"
)

foreach ($imagem in $imagens) {
    Write-Host "Baixando $imagem..."
    docker pull $imagem
}

Write-Host "Ambiente pronto para desenvolvimento!"
```

## 📝 Dicas e Melhores Práticas

1. **Mantenha uma lista de imagens mínima** - Espelhe apenas as imagens que você realmente precisa

2. **Use imagens base oficiais** - Prefira imagens oficiais e com boa reputação

3. **Especifique tags exatas** - Evite usar tags como "latest" para garantir consistência

4. **Escaneie regularmente** - Vulnerabilidades novas são descobertas diariamente

5. **Configure CI/CD para atualização automática** - Automatize o processo de atualização das imagens

6. **Documente as imagens** - Mantenha descrições claras sobre para que cada imagem é usada

7. **Use imagens slim/alpine** quando possível - São menores e geralmente têm menos vulnerabilidades

---

## 📚 Recursos Adicionais

- [Documentação do Azure Container Registry](https://docs.microsoft.com/pt-br/azure/container-registry/)
- [Guia de Segurança para Imagens Docker](https://docs.docker.com/develop/security-best-practices/)
- [Documentação do Trivy](https://aquasecurity.github.io/trivy/v0.44/)
- [Limites de rate limit do Docker Hub](https://docs.docker.com/docker-hub/download-rate-limit/)
