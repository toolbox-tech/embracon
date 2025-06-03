# Imagem oficial Embracon
# Criado por: jose.victor, 26/09/2023

FROM openjdk:17-slim-buster

 

ARG ENVIRONMENT
ARG BUILD_ARGS
ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS

 

WORKDIR /project
COPY . .

 

RUN chmod +x ./gradlew
RUN ./gradlew clean build

 

WORKDIR /app
RUN ls /project/build/libs
RUN mv /project/build/libs/cota-0.0.1-SNAPSHOT.jar api.jar

 

RUN rm -rf /project

CMD java -Dspring.profiles.active=$ENV -Djdk.tls.client.protocols=TLSv1.2 -Dserver.port=80 -Duser.timezone=America/Sao_Paulo $BUILD -jar api.jar


