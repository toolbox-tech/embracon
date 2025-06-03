
# Imagem oficial Embracon para projeto FileServiceapi
# Criado por: jose.victor, 07/04/2025
FROM maven:3.9.6-eclipse-temurin-21 AS base

RUN apt-get update && apt-get install -y openssl ca-certificates


RUN openssl s_client -showcerts -connect api-des.embraconnet.com.br:443 < /dev/null | \
    openssl x509 -outform PEM > /tmp/repo-cert-des.crt && \
    keytool -import -trustcacerts -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit -noprompt -alias embracon-dev -file /tmp/repo-cert-des.crt && \
    rm /tmp/repo-cert-des.crt

RUN openssl s_client -showcerts -connect api-hom.embraconnet.com.br:443 < /dev/null | \
    openssl x509 -outform PEM > /tmp/repo-cert-hom.crt && \
    keytool -import -trustcacerts -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit -noprompt -alias embracon-hom -file /tmp/repo-cert-hom.crt && \
    rm /tmp/repo-cert-hom.crt

RUN openssl s_client -showcerts -connect api.embraconnet.com.br:443 < /dev/null | \
    openssl x509 -outform PEM > /tmp/repo-cert-prod.crt && \
    keytool -import -trustcacerts -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit -noprompt -alias embracon-prod -file /tmp/repo-cert-prod.crt && \
    rm /tmp/repo-cert-prod.crt


FROM base AS build

WORKDIR /app
COPY . .

RUN mvn  clean package -DskipTests


FROM eclipse-temurin:21-jdk

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

CMD ["java", "-jar", "app.jar"]
