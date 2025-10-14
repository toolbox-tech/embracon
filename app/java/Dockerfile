# Runtime otimizado - Tomcat latest com OpenJDK (Eclipse Temurin) - SHA256 específica
FROM tomcat@sha256:f65ab8e0e7388753b17a2ab50aa45692110d5d03fb068fb8d29a93f6ebd637f0

# Definir variáveis de ambiente para otimização
ENV CATALINA_OPTS="-Xms512m -Xmx1024m -server"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Criar usuário não-root para segurança
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat

# Remove o webapp padrão e aplicações de exemplo
RUN rm -rf /usr/local/tomcat/webapps/* && \
    rm -rf /usr/local/tomcat/temp/* && \
    rm -rf /usr/local/tomcat/logs/*

# Copia o WAR pré-compilado (deve ser fornecido via context)
COPY target/java-1.0.war /usr/local/tomcat/webapps/ROOT.war

# Definir permissões corretas
RUN chown -R tomcat:tomcat /usr/local/tomcat

# Usar usuário não-root
USER tomcat

# Expor porta padrão do Tomcat
EXPOSE 8080

# Health check para container (usando wget que está disponível na imagem)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# O Tomcat já inicia automaticamente via CMD da imagem base