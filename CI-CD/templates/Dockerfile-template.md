# Dockerfile Template

Este arquivo serve como modelo para criação de Dockerfiles em projetos CI/CD.

## Exemplo de uso

```dockerfile
# Escolha a imagem base
FROM node:18-alpine

# Defina o diretório de trabalho
WORKDIR /app

# Copie os arquivos de dependências
COPY package*.json ./

# Instale as dependências
RUN npm install

# Copie o restante do código
COPY . .

# Exponha a porta da aplicação
EXPOSE 3000

# Comando para iniciar a aplicação
CMD ["npm", "start"]
```

> Personalize conforme necessário para seu projeto.