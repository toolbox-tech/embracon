# Estágio 1: Construção da aplicação
FROM debian:bullseye-slim AS builder

# Definir variáveis de ambiente para o estágio de construção
ARG ENVIRONMENT=default
ARG BUILD_ARGS
ARG CERT_HOST_1
ARG CERT_PORT_1
ARG CERT_HOST_2
ARG CERT_PORT_2
ARG release=12
ARG update=1

# Definir variáveis de ambiente
ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS
ENV CERT_HOST_1=$CERT_HOST_1
ENV CERT_PORT_1=$CERT_PORT_1
ENV CERT_HOST_2=$CERT_HOST_2
ENV CERT_PORT_2=$CERT_PORT_2

# Copiar o código da aplicação e realizar o build
WORKDIR /app
COPY . /app

# Criar diretório para certificados
RUN mkdir -p /app/lib/certificates

# Instalar Maven e dependências
RUN apt-get update -y && apt-get install -y \
    maven \
    gnupg2 \
    curl \
    ca-certificates \
    && apt-get clean

# Baixar e instalar o JDK 21 manualmente
RUN curl -L -o /tmp/jdk-21_linux-x64_bin.tar.gz https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz \
    && tar -xzf /tmp/jdk-21_linux-x64_bin.tar.gz -C /opt \
    && rm /tmp/jdk-21_linux-x64_bin.tar.gz \
    && ln -s /opt/jdk-21* /usr/local/java

# Definir o JAVA_HOME para o JDK 21 e atualizar o PATH
ENV JAVA_HOME=/usr/local/java
ENV PATH="$JAVA_HOME/bin:$PATH"

# Compilar a aplicação com o Maven
RUN mvn clean install -DskipTests

# Verificar se os certificados estão presentes
RUN ls -l /app/lib/certificates/ || echo "Diretório de certificados vazio"

# Estágio 2: Imagem final
FROM debian:bullseye-slim

# Atualizar pacotes e instalar dependências necessárias
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    unzip \
    && apt-get clean

# Baixar e instalar o JDK 21 manualmente
RUN curl -L -o /tmp/jdk-21_linux-x64_bin.tar.gz https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz \
    && tar -xzf /tmp/jdk-21_linux-x64_bin.tar.gz -C /opt \
    && rm /tmp/jdk-21_linux-x64_bin.tar.gz \
    && ln -s /opt/jdk-21* /usr/local/java

# Definir o JAVA_HOME para o JDK 21 e atualizar o PATH
ENV JAVA_HOME=/usr/local/java
ENV PATH="$JAVA_HOME/bin:$PATH"

# Criar pasta para a aplicação
RUN mkdir -p /app
WORKDIR /app

# Copiar o artefato JAR da imagem 'builder' para a imagem final
COPY --from=builder /app/target/*.jar /app/api.jar

# Copiar os certificados, evitando erro se a pasta estiver vazia
RUN mkdir -p /usr/lib/certs
COPY --from=builder /app/lib/certificates /usr/lib/certs

# Importar certificados para o cacerts (evita erro se a pasta estiver vazia)
RUN find /usr/lib/certs -name "*.crt" -type f -exec keytool -import -trustcacerts -file {} -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -noprompt \;

# Testar se o Java está instalado corretamente
RUN ls -l /usr/local/java/bin && java -version

# Limpar pacotes não utilizados
RUN apt-get autoremove -y && apt-get clean

# Comando de inicialização usando a sintaxe JSON

CMD sh -c "java \
  -Dspring.profiles.active=$ENV \
  -Dserver.port=80 \
  -Duser.timezone=America/Sao_Paulo \
  -Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true \
  -Dcom.sun.security.enableAIAcaIssuers=true \
  -Dcom.sun.net.ssl.checkRevocation=false \
  $BUILD \
  -jar api.jar"
