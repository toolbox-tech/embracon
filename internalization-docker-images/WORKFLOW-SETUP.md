# Configuração do Workflow de Espelhamento de Imagens Docker

Este documento explica como configurar o workflow `mirror-docker-images.yml` para espelhar imagens Docker do Docker Hub para o Azure Container Registry (ACR).

## Sobre o Workflow

O workflow `mirror-docker-images.yml` automaticamente importa imagens Docker listadas no arquivo `docker-images.json` para o ACR usando autenticação OIDC com o Azure. 

O workflow é executado:
- Automaticamente todos os dias à meia-noite
- Quando o arquivo `docker-images.json` é modificado
- Manualmente através da interface do GitHub

## Pré-requisitos

1. Uma conta Azure com um Azure Container Registry (ACR) criado
2. Permissões para configurar identidades gerenciadas no Azure
3. Permissões para criar segredos no repositório GitHub

## Configuração OIDC no Azure

Siga os passos descritos no documento [github-actions-oidc.md](../oidc/github-actions-oidc.md) para configurar a autenticação OIDC entre GitHub Actions e Azure.

### Resumo dos passos:

1. Crie uma Identidade Gerenciada no Azure
2. Configure as credenciais federadas para GitHub Actions
3. Atribua as permissões necessárias à identidade (papel Contributor no ACR)

## Configuração de Segredos no GitHub

Adicione os seguintes segredos ao seu repositório GitHub:

1. `AZURE_CLIENT_ID`: O ID do cliente da identidade gerenciada criada
2. `AZURE_TENANT_ID`: O ID do tenant do Azure AD
3. `AZURE_SUBSCRIPTION_ID`: O ID da assinatura do Azure

### Como adicionar os segredos:

1. Acesse seu repositório no GitHub
2. Vá para "Settings" > "Secrets and variables" > "Actions"
3. Clique em "New repository secret" para cada segredo

## Formato do Arquivo docker-images.json

O arquivo `docker-images.json` deve estar no seguinte formato:

```json
{
  "images": [
    {
      "repository": "maven",
      "tag": "3.8.1-jdk-11-slim",
      "description": "Maven com JDK 11 Slim",
      "targetRepository": "maven"
    },
    {
      "repository": "openjdk",
      "tag": "11.0.15-jre-slim",
      "description": "OpenJDK 11 JRE Slim",
      "targetRepository": "java"
    }
  ]
}
```

Onde:
- `repository`: O nome do repositório no Docker Hub
- `tag`: A tag específica da imagem
- `description`: Descrição da imagem (usado para documentação)
- `targetRepository`: O nome do repositório de destino no ACR (será prefixado com "embracon-")

## Verificando a Execução

Após a configuração:

1. Acesse a aba "Actions" no GitHub
2. Execute o workflow manualmente clicando em "Run workflow"
3. Verifique os logs para garantir que as imagens estejam sendo espelhadas corretamente

## Solução de Problemas

### Problema com Autenticação OIDC

Verifique se:
- As credenciais federadas estão configuradas corretamente
- Os segredos estão configurados no GitHub
- A identidade gerenciada possui permissões suficientes no ACR

### Falha ao Importar Imagens

Verifique se:
- A imagem existe no Docker Hub com a tag especificada
- O ACR está acessível pela identidade gerenciada
- Há espaço suficiente no ACR

## Contato para Suporte

Para questões relacionadas à configuração ou problemas com o workflow, entre em contato com a equipe DevOps da Embracon.
