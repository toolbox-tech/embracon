FROM redis:7.4.2

# Criar diretorio do connector
USER root
RUN mkdir /opt/redis

# Copiar o script
COPY /expire.sh /opt/redis

# Permissao de execucao nos scripts de startup
RUN chmod -R 755 /opt/redis/*.sh

# Definir workspace
WORKDIR /opt/redis

# Executar
CMD ["bash", "-c", "/opt/redis/expire.sh ${REDIS_HOST} ${REDIS_PASSWORD}"]