# Multi-stage build otimizado para cache
# Stage 1: Build da aplicação
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

# Set the working directory in the container
WORKDIR /app

# Copiar apenas pom.xml primeiro para aproveitar cache das dependências
COPY pom.xml .

# Baixar dependências (esta camada será cached se pom.xml não mudar)
RUN mvn dependency:go-offline -B

# Copiar código fonte (esta camada só invalida se código mudar)
COPY src ./src

# Build da aplicação
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime otimizado
FROM tomcat:10.1.44-jdk17-openjdk-slim

# Definir variáveis de ambiente para otimização
ENV CATALINA_OPTS="-Xms512m -Xmx1024m -server"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Criar usuário não-root para segurança
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat

# Remove o webapp padrão e aplicações de exemplo
RUN rm -rf /usr/local/tomcat/webapps/* && \
    rm -rf /usr/local/tomcat/temp/* && \
    rm -rf /usr/local/tomcat/logs/*

# Copia o WAR da etapa de build
COPY --from=build /app/target/java-1.0.war /usr/local/tomcat/webapps/ROOT.war

# Definir permissões corretas
RUN chown -R tomcat:tomcat /usr/local/tomcat

# Usar usuário não-root
USER tomcat

# Expor porta padrão do Tomcat
EXPOSE 8080

# Health check para container
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# O Tomcat já inicia automaticamente via CMD da imagem base