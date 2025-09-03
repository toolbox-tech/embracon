# Workflow para Espelhamento de Imagens Docker

Este workflow do GitHub Actions automatiza o processo de espelhamento de imagens Docker do Docker Hub para o Azure Container Registry (ACR).

## 🔄 Funcionalidades

1. **Verificação automática**: Verifica se as imagens já existem no ACR antes de espelhá-las
2. **Prefixo personalizado**: Adiciona o prefixo "embracon-" a todas as imagens espelhadas
3. **Escaneamento de vulnerabilidades**: Executa escaneamento de segurança nas novas imagens
4. **Notificações**: Gera relatórios e notificações sobre o resultado do processo

## ⚙️ Configuração

### Secrets Necessários

Para utilizar este workflow, adicione os seguintes secrets no seu repositório GitHub:

1. **AZURE_CREDENTIALS**: Credenciais de autenticação no Azure (JSON de service principal)
   ```json
   {
     "clientId": "<client-id>",
     "clientSecret": "<client-secret>",
     "subscriptionId": "<subscription-id>",
     "tenantId": "<tenant-id>"
   }
   ```

2. **ACR_USERNAME**: Nome de usuário para autenticação no ACR
3. **ACR_PASSWORD**: Senha para autenticação no ACR

### Variáveis de Ambiente

O workflow utiliza as seguintes variáveis de ambiente que podem ser personalizadas:

- `ACR_NAME`: Nome do seu Azure Container Registry (padrão: embraconacr)
- `ACR_RESOURCE_GROUP`: Nome do grupo de recursos do ACR (padrão: embracon-infra)
- `PREFIX`: Prefixo a ser adicionado às imagens (padrão: embracon-)
- `CONFIG_FILE`: Caminho para o arquivo de configuração das imagens

## 🚀 Uso

### Execução Agendada

Por padrão, o workflow está configurado para executar toda segunda-feira às 3:00 da manhã (UTC).

### Execução Manual

Você pode iniciar o workflow manualmente através da interface do GitHub:

1. Acesse a guia "Actions" no repositório
2. Selecione o workflow "Verificar e Espelhar Imagens Docker para ACR"
3. Clique em "Run workflow"
4. Opcionalmente, altere os parâmetros:
   - **configFile**: Caminho para o arquivo de configuração
   - **forceUpdate**: Marque para forçar atualização de todas as imagens

### Arquivo de Configuração

O workflow utiliza um arquivo JSON com a configuração das imagens a serem verificadas:

```json
{
    "images": [
        {
            "repository": "node",
            "tag": "18-alpine",
            "description": "Node.js 18 em Alpine Linux",
            "targetRepository": "node"
        },
        {
            "repository": "python",
            "tag": "3.10-slim",
            "description": "Python 3.10 versão slim",
            "targetRepository": "python"
        }
    ]
}
```

## 📊 Relatórios

O workflow gera os seguintes relatórios:

1. **Resumo do espelhamento**: Publicado como um comentário no PR/issue ou como uma nova issue
2. **Relatório de vulnerabilidades**: Disponibilizado como um artefato do workflow

## 🔧 Personalização

### Modificando o Schedule

Para alterar a programação de execução, modifique a seção `schedule` no arquivo YAML:

```yaml
on:
  schedule:
    # Formato: minute hour day-of-month month day-of-week
    - cron: '0 3 * * 1'  # Toda segunda-feira às 3:00 da manhã
```

### Ajustando Parâmetros de Escaneamento

Para personalizar o escaneamento de vulnerabilidades, modifique os parâmetros na seção correspondente:

```yaml
./scripts/scan-docker-vulnerabilities.ps1 `
  -ConfigFile $env:CONFIG_FILE `
  -OutputFile "${{ github.workspace }}/vulnerabilities-report.md" `
  -OutputFormat Markdown `
  -MinimumSeverity HIGH  # Altere para CRITICAL, HIGH, MEDIUM ou LOW
```
