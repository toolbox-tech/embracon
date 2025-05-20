# Design de API com Swagger e Stoplight

## Visão Geral

Ferramentas para design, documentação e teste de APIs RESTful:

### Swagger (OpenAPI)
- **Tipo**: Open-source  
- **Especificação**: OpenAPI Specification (OAS)  
- **Componentes Principais**:
  - Swagger Editor (design)
  - Swagger UI (documentação interativa)
  - Swagger Codegen (geração de código)

### Stoplight
- **Tipo**: Plataforma comercial (com free tier)  
- **Destaques**:
  - Designer visual drag-and-drop
  - Mocking integrado
  - Ferramentas de colaboração em equipe

## Comparação Técnica

| Critério               | Swagger                      | Stoplight                   |
|------------------------|-----------------------------|-----------------------------|
| Modelo de licença      | Open-source                | Freemium                    |
| Fluxo recomendado      | Code-first/Design-first    | Design-first                |
| Validação             | Via plugins                | Built-in                    |
| Integração CI/CD      | Compatível                 | Nativa                      |

## Workflow Recomendado

1. **Design**:
   - Definir endpoints e modelos
   - Especificar parâmetros e respostas

2. **Validação**:
   - Verificar conformidade com OAS
   - Aplicar style guides

3. **Documentação**:
   - Gerar docs interativas
   - Adicionar exemplos

4. **Implementação**:
   - Gerar stubs de servidor
   - Desenvolver clientes

## Boas Práticas

✅ **Versionamento**:  
`/v1/recursos` ou cabeçalho `Accept-Version`  

✅ **Padronização**:
- Nomear endpoints no plural (`/clientes`)
- Usar snake_case ou camelCase consistentemente

✅ **Segurança**:
```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
```

## Ferramentas Complementares

- **Prism** (mock server)
- **Spectral** (linting)
- **Postman** (testes)

> **Dica**: Comece com protótipos no Stoplight e migre para Swagger para implementação em produção.

# Exemplo de Design de API com Stoplight

## Estrutura Básica no Stoplight

O Stoplight organiza os projetos em:

```
meu-projeto/
├── APIs/
│   └── api-pedidos.yaml (arquivo OpenAPI principal)
├── Models/
│   ├── Pedido.yaml
│   └── Cliente.yaml
└── Documentation/
    └── Guia-Integracao.md
```

## Exemplo Completo: API de Pedidos

```yaml
# api-pedidos.yaml
openapi: 3.1.0
info:
  title: API de Pedidos
  version: 1.0.0
  description: API para gestão de pedidos eletrônicos
  contact:
    name: Suporte
    email: suporte@empresa.com
servers:
  - url: https://api.empresa.com/v1
    description: Produção
  - url: https://sandbox.api.empresa.com/v1
    description: Ambiente de testes

paths:
  /pedidos:
    get:
      tags:
        - Pedidos
      summary: Listar todos os pedidos
      parameters:
        - $ref: '#/components/parameters/pagina'
        - $ref: '#/components/parameters/limite'
      responses:
        '200':
          description: Lista de pedidos retornada com sucesso
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ListaPedidos'

    post:
      tags:
        - Pedidos
      summary: Criar novo pedido
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/NovoPedido'
      responses:
        '201':
          description: Pedido criado com sucesso
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Pedido'

components:
  parameters:
    pagina:
      name: pagina
      in: query
      description: Número da página
      required: false
      schema:
        type: integer
        default: 1
    limite:
      name: limite
      in: query
      description: Itens por página
      required: false
      schema:
        type: integer
        default: 10

  schemas:
    Pedido:
      type: object
      properties:
        id:
          type: string
          format: uuid
          example: "550e8400-e29b-41d4-a716-446655440000"
        cliente:
          $ref: '#/components/schemas/Cliente'
        itens:
          type: array
          items:
            $ref: '#/components/schemas/ItemPedido'
        status:
          type: string
          enum: [novo, processando, enviado, entregue]
          example: "novo"

    NovoPedido:
      type: object
      required:
        - clienteId
        - itens
      properties:
        clienteId:
          type: string
          format: uuid
        itens:
          type: array
          minItems: 1
          items:
            $ref: '#/components/schemas/ItemPedido'
```

## Recursos Exclusivos do Stoplight

### 1. Design Visual
Exemplo Stoplight Studio

- **Drag-and-drop** para criar endpoints
- **Autocompletes** para schemas existentes
- **Validação em tempo real**

### 2. Mocking Automático
```bash
# O Stoplight gera um endpoint mock automaticamente
GET https://api.empresa.com/mock/pedidos
```

### 3. Style Guides
Exemplo de regra de validação:
```yaml
rules:
  must-have-api-version:
    description: APIs devem ter versionamento
    given: $.info.version
    then:
      field: version
      function: truthy
```

### 4. Documentação Automática
Documentação Stoplight

- Gera docs interativas automaticamente
- Suporte a Markdown para explicações adicionais
- Visualização de exemplos de requests/responses

## Fluxo de Trabalho Recomendado

1. **Criar modelos** (Models) primeiro
2. **Definir endpoints** baseados nos modelos
3. **Configurar style guides** para consistência
4. **Gerar mock server** para testes iniciais
5. **Compartilhar** com a equipe para feedback
6. **Exportar OpenAPI** para desenvolvimento

## Vantagens do Stoplight

- ✅ **Colaboração em equipe** com comentários e revisões
- ✅ **Governança** com style guides aplicáveis
- ✅ **Geração de código** para várias linguagens
- ✅ **Integração contínua** (GitHub, GitLab, etc.)

# Exemplo de Design de API com Swagger/OpenAPI

## Estrutura Básica no Swagger

O ecossistema Swagger organiza o desenvolvimento em:

```
projeto-api/
├── swagger/
│   ├── api.yml          # Arquivo OpenAPI principal
│   ├── schemas/         # Modelos compartilhados
│   └── parameters/      # Parâmetros reutilizáveis
├── docs/                # Documentação gerada
└── generated/           # Código gerado automaticamente
```

## Exemplo Completo: API de Clientes

```yaml
# api.yml
openapi: 3.0.3
info:
  title: API de Clientes
  version: 1.0.0
  description: API para gestão de cadastro de clientes
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://api.empresa.com/v1
    description: Servidor de produção
  - url: https://sandbox.api.empresa.com/v1
    description: Ambiente de testes

paths:
  /clientes:
    get:
      tags:
        - Clientes
      summary: Lista clientes cadastrados
      parameters:
        - $ref: '#/components/parameters/pagina'
        - $ref: '#/components/parameters/limite'
      responses:
        '200':
          description: Listagem de clientes
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ListaClientes'
        '500':
          $ref: '#/components/responses/ErroServidor'

    post:
      tags:
        - Clientes
      summary: Cadastra novo cliente
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/NovoCliente'
      responses:
        '201':
          description: Cliente criado com sucesso
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Cliente'
        '400':
          $ref: '#/components/responses/ErroValidacao'

  /clientes/{id}:
    get:
      tags:
        - Clientes
      summary: Obtém detalhes de um cliente
      parameters:
        - $ref: '#/components/parameters/idCliente'
      responses:
        '200':
          description: Dados do cliente
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Cliente'
        '404':
          $ref: '#/components/responses/NaoEncontrado'

components:
  parameters:
    pagina:
      in: query
      name: pagina
      schema:
        type: integer
        default: 1
      description: Número da página para paginação
    limite:
      in: query
      name: limite
      schema:
        type: integer
        default: 20
      description: Quantidade de itens por página
    idCliente:
      in: path
      name: id
      required: true
      schema:
        type: string
        format: uuid
      description: ID único do cliente

  schemas:
    Cliente:
      type: object
      properties:
        id:
          type: string
          format: uuid
          example: "123e4567-e89b-12d3-a456-426614174000"
        nome:
          type: string
          example: "João Silva"
        email:
          type: string
          format: email
          example: "joao@empresa.com"
        dataCadastro:
          type: string
          format: date-time
    NovoCliente:
      type: object
      required:
        - nome
        - email
      properties:
        nome:
          type: string
        email:
          type: string
          format: email
        telefone:
          type: string
    ListaClientes:
      type: object
      properties:
        dados:
          type: array
          items:
            $ref: '#/components/schemas/Cliente'
        total:
          type: integer

  responses:
    ErroValidacao:
      description: Dados inválidos
      content:
        application/json:
          schema:
            type: object
            properties:
              erro:
                type: string
                example: "ValidationError"
              detalhes:
                type: array
                items:
                  type: string
                example: ["O campo email é obrigatório"]
    NaoEncontrado:
      description: Recurso não encontrado
    ErroServidor:
      description: Erro interno do servidor
```

## Recursos do Ecossistema Swagger

### 1. Swagger Editor
Swagger Editor

- Editor YAML/JSON online ou local
- Validação em tempo real
- Pré-visualização da documentação

### 2. Swagger UI
```bash
# Para executar localmente:
npm install swagger-ui-dist
```

Exemplo de documentação gerada:
![Swagger UI](https://swagger.io/swagger-ui.png)

### 3. Swagger Codegen
```bash
# Gerar client SDK:
java -jar swagger-codegen-cli.jar generate \
  -i api.yml \
  -l typescript-axios \
  -o ./generated/client
```

Linguagens suportadas:
- Java
- Python
- JavaScript/TypeScript
- C#
- Go
- PHP
- Ruby

### 4. Validação e Linting
```bash
# Instalar o validador:
npm install -g swagger-cli

# Validar especificação:
swagger-cli validate api.yml

# Linting com Spectral:
npm install -g @stoplight/spectral
spectral lint api.yml
```

## Fluxo de Trabalho Recomendado

1. **Projetar** a API no Swagger Editor
2. **Validar** a especificação
3. **Gerar documentação** com Swagger UI
4. **Criar stubs** do servidor com Codegen
5. **Desenvolver** a implementação real
6. **Manter sincronizado** o arquivo OpenAPI

## Vantagens do Swagger

- ✅ **Padrão aberto** (OpenAPI Specification)
- ✅ **Multiplataforma** (todas as linguagens principais)
- ✅ **Ecossistema maduro** (ferramentas para todas as etapas)
- ✅ **Integração CI/CD** (validação automática)
- ✅ **Extensibilidade** (plugins e extensões)

## Exemplo de Uso com Node.js

1. Criar servidor a partir do YAML:
```javascript
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
const swaggerDocument = YAML.load('api.yml');

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
```

2. Gerar client TypeScript:
```bash
openapi-generator-cli generate \
  -i api.yml \
  -g typescript-axios \
  -o src/client-api
```