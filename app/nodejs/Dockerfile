# Embracon Toolbox - Secure Node.js Dockerfile
# Multi-stage build para segurança e otimização

# Stage 1: Build
FROM node:20-alpine AS builder

# Metadados da imagem
LABEL maintainer="Time Toolbox <dev@tbxtech.com>"
LABEL version="1.0.0"
LABEL description="Secure Node.js application with vulnerability fixes"

# Instalar dependências de sistema necessárias
RUN apk add --no-cache dumb-init \
    && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 -G nodejs

# Configurar diretório de trabalho
WORKDIR /app

# Copiar apenas os package files para otimizar cache
COPY package*.json ./

# Copiar código fonte (sem node_modules, só o necessário)
COPY . .

# Stage 2: Production
FROM node:20-alpine AS production

RUN apk add --no-cache dumb-init \
    && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 -G nodejs

WORKDIR /app

# Copiar node_modules do stage anterior
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copiar código fonte
COPY --from=builder --chown=nodejs:nodejs /app . 

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

EXPOSE 8080

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "server.js"]
