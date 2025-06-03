# Imagem oficial Embracon
# Criado por: alves.filipe, 26/12/2022
FROM maven:3.6.3-openjdk-17-slim AS builder 

ARG ENVIRONMENT
ARG BUILD_ARGS

RUN mkdir app
WORKDIR /app
COPY . /app

RUN mvn -DskipTests=true clean package

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

CMD java -Dspring.profiles.active=$ENV -Dserver.port=80 -Duser.timezone=America/Sao_Paulo $BUILD -Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true -Dcom.sun.security.enableAIAcaIssuers=true -jar api.jar