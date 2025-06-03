# Imagem oficial Embracon
# Criado por: alves.filipe, 26/12/2022
FROM sa-saopaulo-1.ocir.io/grxpv7i9yybu/dev/kaas-api-base:latest AS builder

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

COPY --from=builder /app/target/*.jar /app/api.jar

# instalar curl para o health check sensedia de callback
RUN apt-get update
RUN apt-get install -y curl

# TODO INSTALAR SOFTWARES DE SEGURANCA
# yum -y install ciberark
# yum -y install antivirus
# yum -y install tracer

CMD java -Dspring.profiles.active=$ENV -Djdk.tls.client.protocols=TLSv1.2 -Dserver.port=80 -Duser.timezone=America/Sao_Paulo $BUILD -jar api.jar