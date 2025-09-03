# Docker Image Mirror - Azure Container Registry

Este diretório contém scripts para ajudar com a gestão e espelhamento de imagens Docker do Docker Hub para o Azure Container Registry (ACR). Esta abordagem ajuda a:

1. **Mitigar limites de rate limit** do Docker Hub
2. **Melhorar a confiabilidade** dos pipelines de CI/CD
3. **Acelerar o tempo de deploy** ao usar imagens armazenadas localmente
4. **Escanear vulnerabilidades** nas imagens antes de usá-las em produção

## 📋 Scripts Disponíveis

### 🔄 1. mirror-dockerhub-to-acr.ps1

Script que espelha imagens do Docker Hub para o ACR, automatizando o processo de pull, tag e push.

**Uso:**

```powershell
./mirror-dockerhub-to-acr.ps1 -ConfigFile ./docker-images.json -AcrName embraconacr -AcrResourceGroup embracon-infra
```

**Parâmetros:**

- `ConfigFile`: Caminho para o arquivo JSON com a lista de imagens a serem espelhadas
- `AcrName`: Nome do seu Azure Container Registry
- `AcrResourceGroup`: Grupo de recursos do ACR
- `TargetRepository` (opcional): Repositório de destino no ACR (default: 'mirrors')
- `SubscriptionId` (opcional): ID da assinatura Azure

### 🔍 2. scan-docker-vulnerabilities.ps1

Script que analisa vulnerabilidades nas imagens Docker listadas no arquivo de configuração, usando a ferramenta Trivy.

**Uso:**

```powershell
./scan-docker-vulnerabilities.ps1 -ConfigFile ./docker-images.json -OutputFile ./vulnerabilities-report.md -OutputFormat Markdown
```

**Parâmetros:**

- `ConfigFile`: Caminho para o arquivo JSON com a lista de imagens a serem analisadas
- `OutputFile` (opcional): Caminho para o arquivo de saída do relatório
- `OutputFormat` (opcional): Formato de saída do relatório (JSON, CSV, Markdown)

## 🗄️ Arquivo de Configuração

O arquivo `docker-images.json` contém a lista de imagens a serem espelhadas e/ou analisadas:

```json
{
    "images": [
        {
            "repository": "maven",
            "tag": "3.6.3-openjdk-17-slim",
            "description": "Maven com OpenJDK 17 Slim",
            "targetRepository": "maven"
        },
        ...
    ]
}
```

**Atributos:**

- `repository`: O nome do repositório da imagem
- `tag`: A tag da versão da imagem
- `description`: Descrição amigável da imagem
- `targetRepository`: (Opcional) Subdiretório específico no ACR para armazenar a imagem

## ⚙️ Pré-requisitos

- Docker CLI instalado e configurado
- Azure CLI instalado e autenticado
- PowerShell 7+ (pwsh)
- Para o escaneamento: [Trivy](https://github.com/aquasecurity/trivy#installation) instalado

## 🚀 Fluxo de Trabalho Recomendado

1. **Configure as imagens** no arquivo `docker-images.json`
2. **Analise vulnerabilidades** executando o script de escaneamento
3. **Espelhe as imagens aprovadas** para o ACR
4. **Atualize seus Dockerfiles** para apontar para o ACR em vez do Docker Hub

## ⚠️ Considerações de Segurança

- Recomendamos escanear as imagens antes de espelhá-las para o ACR
- Configure políticas de segurança no ACR para bloqueio de imagens vulneráveis
- Estabeleça um processo regular de atualização das imagens espelhadas

## 📊 Integração com CI/CD

Você pode incorporar estes scripts em seu pipeline CI/CD para automatizar o processo:

```yaml
# Exemplo para Azure DevOps
steps:
- task: PowerShell@2
  displayName: 'Escanear Vulnerabilidades'
  inputs:
    filePath: './scripts/scan-docker-vulnerabilities.ps1'
    arguments: '-ConfigFile ./scripts/docker-images.json -OutputFile $(Build.ArtifactStagingDirectory)/vulnerabilities-report.md -OutputFormat Markdown'

- task: PowerShell@2
  displayName: 'Espelhar Imagens para ACR'
  inputs:
    filePath: './scripts/mirror-dockerhub-to-acr.ps1'
    arguments: '-ConfigFile ./scripts/docker-images.json -AcrName $(acrName) -AcrResourceGroup $(acrResourceGroup)'
```

## 📝 Notas

- Execute os scripts regularmente para manter as imagens atualizadas
- Considere automatizar o processo usando Azure Functions ou Logic Apps
- Mantenha um histórico de vulnerabilidades detectadas para análise de tendências
