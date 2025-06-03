# Imagem oficial Embracon
# Criado por: alves.filipe, 03/05/2022
FROM maven:3.8.1-jdk-11-slim AS builder

ARG ENVIRONMENT
ARG BUILD_ARGS

RUN mkdir app
WORKDIR /app
COPY . /app

RUN mvn -DskipTests=true clean package

FROM openjdk:11.0.15-jre-slim

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

CMD java -Dspring.profiles.active=$ENV -Djdk.tls.client.protocols=TLSv1.2 -Dcom.sun.security.enableAIAcaIssuers=true -Dserver.port=80 -Duser.timezone=America/Sao_Paulo $BUILD -jar api.jar