# Imagem oficial Embracon
# Criado por: alves.filipe, 07/08/2024

# Dependencias
FROM maven:3.6.3-openjdk-17-slim AS DEPS 

ARG ENVIRONMENT
ARG BUILD_ARGS

RUN mkdir /opt/app
WORKDIR /opt/app

COPY . /opt/app

RUN mvn -DcreateChecksum=true -B -e org.apache.maven.plugins:maven-dependency-plugin:3.1.2:go-offline


# Compiler
FROM maven:3.6.3-openjdk-17-slim AS BUILDER

WORKDIR opt/app

COPY --from=DEPS /root/.m2 /root/.m2
COPY --from=DEPS /opt/app/ /opt/app

COPY . /opt/app

RUN mvn -DskipTests=true clean package spring-boot:repackage


# Runner
FROM openjdk:17-slim-buster

ARG ENVIRONMENT
ARG BUILD_ARGS

ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS

RUN mkdir /opt/app
WORKDIR /opt/app

# Copiar o jar do projeto
COPY --from=BUILDER /opt/app/target/*.jar /opt/app/api.jar

# Copiar os arquivos das metricas
COPY --from=BUILDER /opt/app/metrics/*.jar /opt/app/jmx.jar
COPY --from=BUILDER /opt/app/metrics/*.yml /opt/app/jmx.yml

# instalar curl para o health check sensedia de callback
RUN apt-get update
RUN apt-get install -y curl

# TODO INSTALAR SOFTWARES DE SEGURANCA
# yum -y install ciberark
# yum -y install antivirus
# yum -y install tracer

# Expose portas da api e das metricas
EXPOSE 80
EXPOSE 9404

CMD java -Dspring.profiles.active=$ENV -Dserver.port=80 -Duser.timezone=America/Sao_Paulo -javaagent:./jmx.jar=9404:./jmx.yml $BUILD -jar api.jar