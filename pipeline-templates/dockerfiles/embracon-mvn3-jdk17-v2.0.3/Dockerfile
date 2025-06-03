# Imagem oficial Embracon
# Atualizado por: jose.victor, 12/04/2024

# Estágio 1: Compilação
FROM maven:3.6.3-openjdk-17 AS builder
 
# Define o diretório de trabalho e concede permissões
WORKDIR /app
RUN chown -R 1001:1001 /app
 
COPY . .
 
RUN mvn -DskipTests=true clean package
 
# Estágio 2: Execução
FROM openjdk:17-slim-buster
 
ARG ENVIRONMENT
ARG BUILD_ARGS
 
ENV ENV=$ENVIRONMENT
ENV BUILD=$BUILD_ARGS
 
WORKDIR /app
 
COPY --from=builder --chown=1001:1001 /app/target/*.jar /app/api.jar
 
# Importar e instalar o certificado na JVM sem senha
##COPY --from=builder /app/src/main/resources/certificados/_.embraconnet.com.br.crt /usr/local/share/ca-certificates/
##RUN update-ca-certificates
 
# Instalar curl para o health check Sensedia de callback (se necessário)
# RUN apt-get update && apt-get install -y curl
 
# Instalar softwares de segurança (se necessário)
# RUN apt-get update && apt-get install -y ciberark antivirus tracer
 
CMD java -Dspring.profiles.active=$ENV -Dserver.port=80 -Duser.timezone=America/Sao_Paulo $BUILD -jar api.jar