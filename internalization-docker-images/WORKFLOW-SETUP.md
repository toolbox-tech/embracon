# Configuração dos Workflows de Espelhamento de Imagens Docker

Este documento explica como configurar os workflows de espelhamento de imagens Docker para o Azure Container Registry (ACR).

## Sobre os Workflows

Existem dois workflows para espelhamento de imagens:

1. **`mirror-docker-images.yml`**: Espelha imagens públicas do Docker Hub listadas no arquivo `docker-public-images.json`
2. **`mirror-private-docker-images.yml`**: Espelha imagens privadas de registros personalizados listadas no arquivo `docker-private-images.json`

Ambos os workflows utilizam autenticação OIDC com o Azure para acesso ao ACR. 

Os workflows são executados:
- **Workflow de imagens públicas**:
  - Automaticamente todos os dias à meia-noite
  - Quando o arquivo `docker-public-images.json` é modificado
  - Manualmente através da interface do GitHub

- **Workflow de imagens privadas**:
  - Automaticamente todos os dias às 2 da manhã
  - Quando o arquivo `docker-private-images.json` é modificado
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

### Segredos Necessários para Ambos os Workflows

Adicione os seguintes segredos ao seu repositório GitHub:

#### Autenticação no Docker Hub

1. **`DOCKERHUB_USERNAME`**: Nome de usuário do Docker Hub
2. **`DOCKERHUB_TOKEN`**: Token de acesso do Docker Hub (não use senha, use token)

Para criar um token do Docker Hub:
1. Faça login na sua conta Docker Hub
2. Acesse "Account Settings" > "Security" > "New Access Token"
3. Dê um nome para o token e configure as permissões necessárias
4. Copie o token gerado e adicione como secret no GitHub

#### Autenticação no Azure Container Registry

1. **`ACR_USERNAME`**: Nome de usuário do ACR (geralmente o nome do ACR)
2. **`ACR_PASSWORD`**: Senha ou token de acesso do ACR

Para obter as credenciais do ACR:
```bash
# Obter as credenciais de admin do ACR
az acr credential show --name embraconacr --resource-group embracon-infra
```

Se as credenciais admin estiverem desabilitadas, você pode habilitá-las:
```bash
# Habilitar credenciais de admin
az acr update --name embraconacr --resource-group embracon-infra --admin-enabled true
```

Para maior segurança, considere criar um token do ACR com permissões limitadas:
```bash
# Criar um token para uso nos workflows
az acr token create --name github-actions --registry embraconacr --repository "*" --scope-map _repositories_pull_push
```

### Como adicionar os segredos:

1. Acesse seu repositório no GitHub
2. Vá para "Settings" > "Secrets and variables" > "Actions"
3. Clique em "New repository secret" para cada segredo

## Formato dos Arquivos de Configuração

### Arquivo `docker-public-images.json`

O arquivo para imagens públicas deve estar no seguinte formato:

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

### Arquivo `docker-private-images.json`

O arquivo para imagens privadas deve estar no seguinte formato:

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

**Observação de Segurança**: As credenciais de autenticação são armazenadas como secrets no GitHub, não no arquivo JSON.

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
