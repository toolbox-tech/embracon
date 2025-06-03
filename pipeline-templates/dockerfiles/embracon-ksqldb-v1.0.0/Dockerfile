# FROM confluentinc/cp-kafka-connect:7.1.0
FROM confluentinc/cp-ksqldb-cli:7.6.0

# Criar diretorio do connector
USER root
RUN mkdir /opt/ksql
WORKDIR /opt/ksql

# Mover os arquivos de setup
COPY /ssl /opt/ksql
COPY /clusters /opt/ksql

# Instalar o certificado e dar permissao de execucao no script
RUN keytool -noprompt -storepass changeit -keypass changeit -importcert -trustcacerts -alias confluentca -file /opt/ksql/confluent.crt -keystore /usr/lib/jvm/zulu11-ca/lib/security/cacerts -storepass changeit

# Alterar user (boa pratica)
USER appuser
