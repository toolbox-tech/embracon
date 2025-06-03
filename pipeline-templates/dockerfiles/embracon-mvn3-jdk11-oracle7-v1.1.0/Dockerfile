# Imagem oficial Embracon
# Criado por: alves.filipe, 03/05/2022
FROM maven:3.8.1-jdk-11-slim AS builder

ARG ENVIRONMENT
ARG BUILD_ARGS

RUN mkdir app
WORKDIR /app
COPY . /app

RUN mvn -DskipTests=true clean package

# Imagem oficial Embracon
# Criado por: alves.filipe, 03/05/2022
FROM oraclelinux:7-slim

ARG ENVIRONMENT
ARG BUILD_ARGS
ARG release=19
ARG update=3

ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS

RUN  yum -y install oracle-release-el7 && yum-config-manager --enable ol7_oracle_instantclient && \
     yum -y install oracle-instantclient${release}.${update}-basic oracle-instantclient${release}.${update}-devel oracle-instantclient${release}.${update}-sqlplus && \
     rm -rf /var/cache/yum

RUN yum install java-11-openjdk -y

RUN mkdir app
WORKDIR /app

RUN yum install -y curl

COPY --from=builder /app/lib/oracle/wallet/* /usr/lib/oracle/${release}.${update}/client64/lib/network/admin/
COPY --from=builder /app/target/*.jar /app/api.jar


# TODO INSTALAR SOFTWARES DE SEGURANCA
# yum -y install ciberark
# yum -y install antivirus
# yum -y install tracer

CMD java -Dspring.profiles.active=$ENV -Dcom.sun.security.enableAIAcaIssuers=true -Dserver.port=80 -Djdk.tls.client.protocols=TLSv1.2 -Duser.timezone=America/Sao_Paulo $BUILD -jar api.jar
