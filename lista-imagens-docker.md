<p align="center">
  <img src="./img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# 🐳 Lista de Imagens Docker Utilizadas

Este documento lista todas as imagens base Docker utilizadas nos Dockerfiles da pasta `pipeline-templates`. Estas imagens são a base para os containers utilizados nos pipelines CI/CD da Embracon.

## 📊 Resumo por Categorias

### 🟢 Linguagens de Programação

| Categoria | Imagens | Versões |
|-----------|---------|---------|
| **Java/JDK** | openjdk, eclipse-temurin | 11, 17, 18, 21, 22 |
| **Node.js** | node | 18 |
| **PHP** | php | 7.2-apache |
| **Python** | ubuntu + python3 | 20.04 + python3 |

### 🟡 Ferramentas de Build

| Categoria | Imagens | Versões |
|-----------|---------|---------|
| **Maven** | maven | 3.6.3, 3.8.1, 3.8.6, 3.9.6 |

### 🔴 Sistemas Operacionais Base

| Categoria | Imagens | Versões |
|-----------|---------|---------|
| **Debian** | debian | bullseye-slim |
| **Ubuntu** | ubuntu | 18.04, 20.04 |
| **Oracle Linux** | oraclelinux | 7-slim |

### 🔵 Ferramentas de Dados

| Categoria | Imagens | Versões |
|-----------|---------|---------|
| **Redis** | redis | 7.4.2 |
| **Kafka** | confluentinc/cp-server-connect | 7.1.0, 7.7.0 |
| **KSQLDB** | confluentinc/cp-ksqldb-cli | 7.6.0 |

## 📋 Lista Completa de Imagens (Ordenada)

| Imagem | Versão | Uso | Dockerfile |
|--------|--------|-----|------------|
| confluentinc/cp-ksqldb-cli | 7.6.0 | KSQL CLI | embracon-ksqldb-v1.0.0 |
| confluentinc/cp-server-connect | 7.1.0 | Kafka Connect | embracon-kafka-connect-v1.0.0 |
| confluentinc/cp-server-connect | 7.7.0 | Kafka Connect | embracon-kafka-connect-v1.1.0 |
| debian | bullseye-slim | Base para JDK | embracon-mvn3-jdk22-cert-v2.0.0 |
| eclipse-temurin | 21-jdk | JDK 21 | embracon-mvn3-jdk21-v1.0.0 |
| maven | 3.6.3-openjdk-17 | Build Java | embracon-mvn3-jdk17-v2.0.3 |
| maven | 3.6.3-openjdk-17-slim | Build Java | embracon-mvn3-jdk17-v1.0.0, v1.0.1, v1.1.0, v3.0.0, v3.0.1 |
| maven | 3.8.1-jdk-11-slim | Build Java | embracon-mvn3-jdk11-v1.0.1 até v2.1.1, cert e oracle7 |
| maven | 3.8.6-openjdk-18-slim | Build Java | embracon-mvn3-jdk18-v1.0.0 |
| maven | 3.9.6-eclipse-temurin-21 | Build Java | embracon-mvn3-jdk21-v1.0.0 |
| node | 18 | Node.js | embracon-node-18 |
| openjdk | 11.0.15-jre-slim | JRE | embracon-mvn3-jdk11-* (múltiplas versões) |
| openjdk | 17-slim-buster | JDK 17 | embracon-mvn3-jdk17-* (múltiplas versões) |
| openjdk | 18-slim-buster | JDK 18 | embracon-mvn3-jdk18-v1.0.0 |
| openjdk | 21-slim-buster | JDK 21 | embracon-jdk21-v1.0.0, v1.0.1 |
| oraclelinux | 7-slim | Oracle Linux | embracon-mvn3-jdk11-oracle7-* |
| php | 7.2-apache | PHP com Apache | embracon-php-7.2-v1.0.0 |
| redis | 7.4.2 | Redis | embracon-redis-v1.0.0 |
| sa-saopaulo-1.ocir.io/grxpv7i9yybu/dev/kaas-api-base | latest | KaaS API | embracon-kaasapi-v1.0.0 |
| ubuntu | 18.04 | Ubuntu | embracon-ubuntu18-v1.0.0, v1.0.1 |
| ubuntu | 20.04 | Ubuntu com Python | embracon-ubuntu20-python3-v1.0.0 |

## 🔍 Detalhes por Tipo de Imagem

### Java/JDK/JRE

- **OpenJDK 11**: Usada principalmente em imagens runtime para aplicações Java mais antigas
- **OpenJDK 17**: Base para aplicações Java modernas, incluindo clientes Kafka
- **OpenJDK 18**: Versão intermediária para casos específicos
- **OpenJDK 21**: Última LTS disponível para aplicações Java mais recentes
- **Eclipse Temurin 21**: Alternativa ao OpenJDK para JDK 21

### Maven

- **Maven 3.6.3**: Versão comum para builds Java com JDK 17
- **Maven 3.8.1**: Versão usada principalmente com JDK 11
- **Maven 3.8.6**: Versão para JDK 18
- **Maven 3.9.6**: Versão mais recente para JDK 21

### Sistemas Operacionais

- **Debian Bullseye Slim**: Usado como base leve para Java
- **Ubuntu 18.04/20.04**: Usado para imagens de propósito geral
- **Oracle Linux 7**: Usado para compatibilidade com aplicações Oracle

### Kafka/Confluent

- **CP-Server-Connect**: Imagens para Kafka Connect
- **CP-KSQLDB-CLI**: CLI para operações KSQL

### Outros

- **Redis**: Banco de dados em memória
- **Node.js**: Aplicações JavaScript
- **PHP**: Aplicações PHP com servidor Apache embutido

---

<p align="center">
  <img src="./img/toolbox-footer.png" alt="Toolbox Footer" width="200"/>
  <br />
  <em>Desenvolvido pelo Time de DevOps & SRE - Embracon</em>
</p>
