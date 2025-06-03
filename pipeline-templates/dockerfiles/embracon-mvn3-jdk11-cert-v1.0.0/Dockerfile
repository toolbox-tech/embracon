# Imagem oficial Embracon
# Criado por: alves.filipe, 03/10/2022
FROM maven:3.8.1-jdk-11-slim AS builder

RUN mkdir app
WORKDIR /app
COPY . /app

RUN ls /app/
RUN mvn clean package

FROM openjdk:11.0.15-jre-slim

ARG ENVIRONMENT
ARG BUILD_ARGS
ARG CERT_HOST
ARG CERT_PORT

ARG release=12
ARG update=1

# Variaveis 
ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS
ENV CERT_HOST=$CERT_HOST
ENV CERT_PORT=$CERT_PORT

# Instalar libs do Oracle
ENV ORACLE_HOME=/usr/lib/oracle/12.1/client64
ENV TNS_ADMIN=/usr/lib/oracle/${release}.${update}/client64/lib/network/admin
ENV LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib

RUN apt-get update -y && apt-get install default-jdk -y

RUN mkdir /usr/lib/certs && mkdir /usr/lib/oracle

COPY --from=builder /app/lib/certificates/* /usr/lib/certs/
COPY --from=builder /app/lib/oracle/wallet/${ENVIRONMENT}/* /usr/lib/oracle/
COPY --from=builder /app/lib/oracle/wallet/general/* /usr/lib/oracle/
COPY --from=builder /app/lib/oracle/wallet/general/* /usr/lib/oracle/${release}.${update}/client64/lib/network/admin/
COPY --from=builder /app/lib/oracle/wallet/${ENVIRONMENT}/* /usr/lib/oracle/${release}.${update}/client64/lib/network/admin/

WORKDIR /usr/lib/oracle

RUN apt-get install alien libaio1 -y unixodbc -y
RUN alien -i oracle-instantclient12.1-*
RUN echo /usr/lib/oracle/12.1/client64/lib/ | tee  /etc/ld.so.conf.d/oracle.conf && chmod o+r /etc/ld.so.conf.d/oracle.conf
RUN mv odbc.ini /etc/odbc.ini && mv odbcinst.ini /etc/odbcinst.ini
RUN tee /etc/profile.d/oracle.sh && chmod o+r /etc/profile.d/oracle.sh && . /etc/profile.d/oracle.sh && mkdir -p $ORACLE_HOME/network/admin

WORKDIR /network/admin
RUN tee -a /etc/profile.d/oracle.sh


# Instalar certificados
WORKDIR /usr/lib/certs

RUN javac InstallCert.java
RUN echo 1 | java InstallCert ${CERT_HOST}:${CERT_PORT}
RUN keytool -exportcert -alias ${CERT_HOST}-1 -keystore jssecacerts -storepass changeit -file ${CERT_HOST}.cer
RUN echo yes | keytool -importcert -alias ${CERT_HOST} -keystore "/usr/local/openjdk-11/lib/security/cacerts" -storepass changeit -file ${CERT_HOST}.cer

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

CMD java -Dspring.profiles.active=$ENV -Dserver.port=80 -Duser.timezone=America/Sao_Paulo $BUILD -jar api.jar