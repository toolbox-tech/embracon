FROM confluentinc/cp-server-connect:7.7.0

# Variaveis
ENV KAFKA_APP_CONNECTOR_NAME "kafka-connector-jornada-cota-c74a00e6"
ENV KAFKA_APP_JDBC_URL "jdbc:db://localhost:port"
ENV KAFKA_APP_JDBC_QUERY "select 1 from dual"
ENV KAFKA_APP_JDBC_USER "user"
ENV KAFKA_APP_JDBC_PASSWORD "pass"

# Criar diretorio do connector
USER root
RUN mkdir /opt/connector
WORKDIR /opt/connector

# Instalar o component do conector e biblioteca jdbc
#RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.6.3
COPY /connector/component/core /usr/share/confluent-hub-components
COPY /connector/component/lib /usr/share/java

# Instalar o component do prometheus para exportar as metricas
COPY /connector/component/metrics /opt/connector/metrics
RUN chmod +rx /opt/connector/metrics/*.jar
RUN chmod +rx /opt/connector/metrics/*.yml

# Mover os arquivos de setup
COPY /connector/config /opt/connector
COPY /connector/data /opt/connector
COPY /connector/scripts /opt/connector
COPY /connector/ssl /opt/connector

# Instalar o certificado e dar permissao de execucao no script
RUN keytool -noprompt -storepass changeit -keypass changeit -importcert -trustcacerts -alias confluentca -file /opt/connector/confluent.crt -keystore /usr/lib/jvm/zulu17-ca/lib/security/cacerts
RUN chmod -R 755 /opt/connector/*.sh

# Alterar user (boa pratica)
# USER appuser

# Expose portas da api do connector e das metricas
EXPOSE 8083
EXPOSE 9404

CMD ["bash", "-c", "/opt/connector/run.sh"]