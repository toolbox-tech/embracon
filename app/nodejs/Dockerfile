FROM node:20-alpine 

# Metadados da imagem
LABEL maintainer="Time Toolbox <dev@tbxtech.com>"
LABEL version="1.0.0"
LABEL description="Secure Node.js application with vulnerability fixes"

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 -G nodejs

RUN ls -lhs

COPY app/ usr/app

RUN ls -lhs

WORKDIR usr/app

RUN ls -lhs

# Configurações de segurança
ENV NODE_ENV=production
ENV NPM_CONFIG_LOGLEVEL=warn
ENV NODE_OPTIONS="--max-old-space-size=1024"

# Health check
COPY --chown=nodejs:nodejs healthcheck.js .
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD node healthcheck.js || exit 1

# Usar usuário não-root
USER nodejs

EXPOSE 8080

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "server.js"]

