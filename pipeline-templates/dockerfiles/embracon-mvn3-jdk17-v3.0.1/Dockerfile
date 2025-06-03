# Imagem oficial Embracon
# Criado por: diego.pita, alves.filipe - 12/06/2024
# Optimazando o builder
FROM maven:3.6.3-openjdk-17-slim AS DEPS

ARG ENVIRONMENT
ARG BUILD_ARGS

RUN mkdir /opt/app
WORKDIR /opt/app

#PREBUILD_COPY#




RUN mvn -B -e -C -DskipTests=true -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true org.apache.maven.plugins:maven-dependency-plugin:3.1.2:go-offline



FROM maven:3.6.3-openjdk-17-slim AS BUILDER

WORKDIR opt/app

COPY --from=deps /root/.m2 /root/.m2
COPY --from=deps /opt/app/ /opt/app

#BUILD_COPY#

RUN mvn -B -e  clean install -DskipTests=true

FROM openjdk:17-slim-buster

ARG ENVIRONMENT
ARG BUILD_ARGS

ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS

RUN mkdir app
WORKDIR /app

COPY --from=builder /opt/app/ms-launcher/target/*.jar /app/api.jar

# instalar curl para o health check sensedia de callback
RUN apt-get update
RUN apt-get install -y curl

# TODO INSTALAR SOFTWARES DE SEGURANCA
# yum -y install ciberark
# yum -y install antivirus
# yum -y install tracer

CMD java -Dspring.profiles.active=$ENV -Dserver.port=80 -Duser.timezone=America/Sao_Paulo $BUILD -jar api.jar
