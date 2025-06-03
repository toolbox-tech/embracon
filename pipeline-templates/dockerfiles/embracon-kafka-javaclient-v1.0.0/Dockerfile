# Imagem oficial Embracon
# Criado por: alves.filipe, 26/12/2022
FROM maven:3.6.3-openjdk-17-slim AS builder 

ARG ENVIRONMENT
ARG BUILD_ARGS

RUN mkdir app
WORKDIR /app
COPY . /app

RUN mvn -DskipTests=true clean package spring-boot:repackage

FROM openjdk:17-slim-buster

ARG ENVIRONMENT
ARG BUILD_ARGS

ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS

RUN mkdir app
WORKDIR /app

# Copiar o jar do projeto
COPY --from=builder /app/target/*.jar /app/api.jar

# Copiar os arquivos das metricas
COPY --from=builder /app/metrics/*.jar /app/jmx.jar
COPY --from=builder /app/metrics/*.yml /app/jmx.yml

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