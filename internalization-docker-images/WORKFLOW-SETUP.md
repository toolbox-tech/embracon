# Configuração dos Workflows de Espelhamento de Imagens Docker

Este documento explica como configurar os workflows de espelhamento de imagens Docker para o Azure Container Registry (ACR).

## Sobre os Workflows

Existem dois workflows para espelhamento de imagens:

1. **`mirror-public-docker-images.yml`**: Espelha imagens públicas do Docker Hub listadas no arquivo `docker-public-images.json`
2. **`mirror-private-docker-images.yml`**: Espelha imagens privadas de registros personalizados listadas no arquivo `docker-private-images.json`

Ambos os workflows possuem duas abordagens de implementação:
- Usando Docker pull e push direto
- Usando o comando `az acr import` (requer permissões especiais no Azure)

## Execução dos Workflows

Os workflows são executados:
- **Workflow de imagens públicas**:
  - Automaticamente todos os dias à meia-noite
  - Quando o arquivo `docker-public-images.json` é modificado
  - Manualmente através da interface do GitHub

- **Workflow de imagens privadas**:
  - Automaticamente todos os dias às 2 da manhã
  - Quando o arquivo `docker-private-images.json` é modificado
  - Manualmente através da interface do GitHub

## Configuração das Variáveis

### Variáveis do Ambiente no GitHub

Configure as seguintes variáveis de ambiente no GitHub:

1. Acesse seu repositório no GitHub
2. Vá para "Settings" > "Secrets and variables" > "Actions" > aba "Variables"
3. Adicione as seguintes variáveis:
| Nome | Tipo | Descrição | Exemplo |
|------|------|-----------|---------|
| `ACR_NAME` | Variável | Nome do Azure Container Registry | `embraconacr` |
| `RESOURCE_GROUP` | Variável | Grupo de recursos do ACR | `embracon-infra` |
| `DOCKERHUB_USERNAME` | Variável | Nome de usuário do Docker Hub | `embraconuser` |

### Segredos no GitHub

Configure os seguintes segredos no GitHub:

1. Acesse seu repositório no GitHub
2. Vá para "Settings" > "Secrets and variables" > "Actions" > aba "Secrets"
3. Adicione os seguintes segredos:

#### Autenticação no Azure (OIDC)

| Nome | Descrição |
|------|-----------|
| `AZURE_CLIENT_ID` | ID do cliente da identidade gerenciada |
| `AZURE_TENANT_ID` | ID do tenant do Azure AD |
| `AZURE_SUBSCRIPTION_ID` | ID da assinatura do Azure |

#### Token de autenticação do Docker Hub

| Nome | Descrição |
|------|-----------|
| `DOCKERHUB_TOKEN` | Token de acesso do Docker Hub |

> **Importante**: Para maior segurança, use tokens com escopo limitado e validade definida, não senhas.

## Formato dos Arquivos de Configuração

### Arquivo `docker-public-images.json`

```json
{
  "images": [
    {
      "repository": "maven",
      "tag": "3.8.1-jdk-11-slim",
      "description": "Maven com JDK 11 Slim",
      "targetRepository": "maven"
    }
  ]
}
```

Onde:
- `repository`: O nome do repositório no Docker Hub
- `tag`: A tag específica da imagem
- `description`: Descrição da imagem (usado para documentação)
- `targetRepository`: O nome do repositório de destino no ACR (será prefixado com "embracon-")

### Arquivo `docker-private-images.json`

```json
{
  "images": [
    {
      "registry": "private-registry.company.com",
      "repository": "my-private-repo/app",
      "tag": "1.0.0",
      "description": "Aplicação privada versão 1.0.0",
      "targetRepository": "private-app"
    }
  ]
}
```

Onde:
- `registry`: O endereço do registro privado
- `repository`: O caminho completo do repositório no registro privado
- `tag`: A tag específica da imagem
- `description`: Descrição da imagem (usado para documentação)
- `targetRepository`: O nome do repositório de destino no ACR (será prefixado com "embracon-")

## Resolução de Problemas

### Erro de Autenticação no Azure

Se encontrar erros de autenticação com Azure OIDC:

1. Verifique se a identidade gerenciada existe no Azure
2. Verifique se as credenciais federadas estão configuradas corretamente
3. Verifique se a identidade tem permissões suficientes no ACR

### Erro de Pull/Push no Docker

Se encontrar erros ao puxar ou enviar imagens:

1. Verifique se as credenciais do Docker Hub estão corretas
2. Verifique se tem permissão para acessar a imagem privada
3. Verifique se o ACR está acessível e tem espaço suficiente

### Erro com `az acr import`

Se encontrar erros ao usar o comando `az acr import`:

1. Verifique se a identidade tem permissões `AcrPush` no ACR
2. Use o método alternativo de Docker pull/push
