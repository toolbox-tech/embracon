<p align="center">
  <img src="../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Hello World Java com Docker

## Uso Local

Para usar o projeto Hello World Java com Docker, siga estes passos:

1. Certifique-se de ter o Docker instalado em sua máquina. Você pode baixar e instalar o Docker a partir do site oficial: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/).

2. Certifique-se que você está dentro do diretório `app/java`.

3. Construa a imagem Docker:
    ```bash
    docker build -t hello-world-java .
    ```
    Obs.: Certifique-se que seu Docker está rodando.

4. Execute o contêiner Docker:
    ```bash
    docker run -p 8080:8080 hello-world-java
    ```

5. Abra seu navegador e visite `http://localhost:8080` para ver a mensagem "Olá, mundo!" da aplicação Java Servlet.

## Sobre a Aplicação

Esta aplicação demonstra:

- **Java Servlet**: Aplicação web usando Jakarta EE Servlet API 5.0
- **Apache Tomcat**: Servidor de aplicação para executar a aplicação web
- **Maven**: Gerenciamento de dependências e build da aplicação
- **Multi-stage Docker Build**: Otimização da imagem Docker usando build em múltiplas etapas
- **Docker**: Containerização da aplicação para deploy consistente

### Estrutura do Projeto

```
app/java/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── exemplo/
│       │           └── HelloServlet.java
│       └── webapp/
│           └── WEB-INF/
│               └── web.xml
├── pom.xml
├── Dockerfile
└── README.md
```

### Tecnologias Utilizadas

- **Java 8+**: Linguagem de programação
- **Jakarta EE Servlet API 5.0**: Framework web para Java
- **Apache Tomcat 10**: Servidor de aplicação
- **Maven 3.8**: Ferramenta de build e gerenciamento de dependências
- **Docker**: Containerização da aplicação

---

<p align="center">
  <strong>🚀 Aplicações de Exemplo 🛡️</strong><br>
    <em>☕ Java Servlet com Docker</em>
</p>
