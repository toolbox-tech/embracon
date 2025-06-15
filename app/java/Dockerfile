# Use an official Maven image as the base image
FROM maven:3.8.4-openjdk-11-slim AS build
# Set the working directory in the container
WORKDIR /app
# Copy the pom.xml and the project files to the container
COPY pom.xml .
COPY src ./src
# Build the application using Maven
RUN mvn clean package

# Usa a imagem oficial do Tomcat com Java 17
FROM tomcat:10-jdk17

# Remove o webapp padrão (opcional)
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copia seu .war para a pasta webapps do Tomcat e renomeia para ROOT.war
COPY --from=build /app/target/java-1.0.war /usr/local/tomcat/webapps/ROOT.war

# O Tomcat já inicia automaticamente