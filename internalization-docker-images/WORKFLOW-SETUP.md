# Configuração dos Workflows de Espelhamento de Imagens Docker

Este documento explica como configurar os workflows de espelhamento de imagens Docker para o Azure Container Registry (ACR).

## Princípio Fundamental: JSON como Fonte Única da Verdade

O sistema de espelhamento de imagens opera sob um princípio fundamental: **o arquivo JSON é a única fonte da verdade**. Isso significa que:

- Somente as imagens listadas no arquivo JSON serão importadas para o ACR
- Qualquer imagem ou repositório presente no ACR que não esteja definido no JSON será automaticamente removido
- Todas as atualizações e modificações devem ser feitas através do arquivo JSON
- O workflow sincroniza completamente o conteúdo do ACR com o que está definido no JSON

Este princípio garante que o processo de internalização de imagens seja totalmente controlado, documentado e auditável.

## Sobre o Workflow

O workflow para espelhamento de imagens é:

1. **`mirror-public-docker-images.yml`**: Espelha imagens públicas do Docker Hub listadas no arquivo `docker-public-images.json` para o Azure Container Registry (ACR)

O workflow utiliza:
- Comando `az acr import` para transferência eficiente de imagens
- Verificação de digest para evitar transferências desnecessárias
- Docker buildx para inspeção de manifestos e digests
- Cache para otimizar a execução

## Execução do Workflow

O workflow é executado:
- Automaticamente todos os dias à meia-noite
- Quando o arquivo `docker-public-images.json` é modificado
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
      "description": "Maven com JDK 11 Slim"
    }
  ]
}
```

Onde:
- `repository`: O nome do repositório no Docker Hub
- `tag`: A tag específica da imagem
- `description`: Descrição da imagem (usado para documentação)

> **Nota**: O nome do repositório de destino no ACR será o mesmo do Docker Hub, prefixado com "embracon-"

**Importante**: Este arquivo JSON é a única fonte da verdade para o gerenciamento das imagens no ACR. Qualquer alteração desejada no conteúdo do ACR (adição, modificação ou remoção de imagens) deve ser feita através deste arquivo. O workflow garante que o conteúdo do ACR seja sempre um reflexo exato do que está definido neste JSON.

## Verificação de Digest e Limpeza

### Verificação de Digest

O workflow implementa uma verificação de digest para evitar transferências desnecessárias:

1. Verifica se a tag da imagem já existe no ACR
2. Obtém o digest da imagem no ACR usando `az acr repository show`
3. Obtém o digest da imagem no Docker Hub usando `docker buildx imagetools inspect`
4. Compara os digests para determinar se a imagem precisa ser atualizada
5. Só realiza a importação se os digests forem diferentes ou se a imagem não existir no ACR

### Limpeza Automática - JSON como Fonte da Verdade

O workflow implementa um princípio fundamental: **o arquivo JSON é a única fonte da verdade**. Qualquer imagem presente no ACR que não esteja listada no JSON será automaticamente removida.

O job de limpeza funciona da seguinte forma:

1. Lê a lista de imagens válidas do arquivo JSON
2. Lista todos os repositórios no ACR que começam com o prefixo definido
3. Remove repositórios inteiros que não estão listados no JSON
4. Para repositórios válidos, remove tags específicas que não estão no JSON

Isso garante a sincronização total entre o que está documentado no JSON e o que está efetivamente armazenado no ACR. Se uma imagem for removida do arquivo JSON, ela será automaticamente removida do ACR na próxima execução do workflow, mantendo o registro limpo e atualizado.

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
