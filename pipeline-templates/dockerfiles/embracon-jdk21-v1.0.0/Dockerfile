# Imagem oficial Embracon
# Criado por: jose.victor, 26/01/2024

FROM openjdk:21-slim-buster

 

ARG ENVIRONMENT
ARG BUILD_ARGS
ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS

 

WORKDIR /project
COPY . .

 

RUN chmod +x ./gradlew
RUN ./gradlew clean build

 

WORKDIR /app
RUN ls /project/core/build/libs
RUN mv /project/core/build/libs/core-0.0.1-SNAPSHOT.jar api.jar

 

RUN rm -rf /project

CMD java -Dspring.profiles.active=$ENV -Dcom.sun.security.enableAIAcaIssuers=true -Djdk.tls.client.protocols=TLSv1.2 -Dserver.port=80 -Duser.timezone=America/Sao_Paulo $BUILD -jar api.jar
