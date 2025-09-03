# Embracon Toolbox - Secure Node.js Dockerfile
# Multi-stage build para segurança e otimização

# Stage 1: Build
FROM node:20-alpine AS builder

# Metadados da imagem
LABEL maintainer="Marrcelo Buzzetti <marcelo.buzzetti@tbxtech.com>"
LABEL version="1.1.0"
LABEL description="Secure Node.js application with vulnerability fixes"

# Instalar dependências de sistema necessárias
RUN apk add --no-cache \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Criar usuário não-root para segurança
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 -G nodejs

# Configurar diretório de trabalho
WORKDIR /app

# Copiar apenas package files para otimizar cache do Docker
COPY package*.json ./

# Stage 2: Production
FROM node:20-alpine AS production

# Instalar dumb-init para signal handling
RUN apk add --no-cache dumb-init \
    && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 -G nodejs

# Configurar diretório de trabalho
WORKDIR /app

# Copiar node_modules do stage anterior
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copiar código fonte
COPY --chown=nodejs:nodejs . .

# Configurações de segurança
ENV NODE_ENV=production
ENV NPM_CONFIG_LOGLEVEL=warn
ENV NODE_OPTIONS="--max-old-space-size=1024"

# Remover arquivos desnecessários
RUN rm -f package-lock.json npm-debug.log* yarn.lock .npmrc 2>/dev/null || true

# Health check
COPY --chown=nodejs:nodejs healthcheck.js .
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD node healthcheck.js || exit 1

# Usar usuário não-root
USER nodejs

# Expor porta
EXPOSE 8080

# Usar dumb-init para signal handling
ENTRYPOINT ["dumb-init", "--"]

# Comando para iniciar a aplicação
CMD ["node", "server.js"]
