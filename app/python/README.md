<p align="center">
  <img src="../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Hello World Python com Docker

## Uso Local

Para usar o projeto Hello World Python com Docker, siga estes passos:

1. Certifique-se de ter o Docker instalado em sua máquina. Você pode baixar e instalar o Docker a partir do site oficial: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/).

2. Certifique-se que você está dentro do diretório `hello-world-com-docker-languages/python`.

3. Construa a imagem Docker:
    ```bash
    docker build -t hello-world-python .
    ```
    Obs.: Certifique-se que seu Docker está rodando.

4. Execute o contêiner Docker:
    ```bash
    docker run -p 5001:5000 hello-world-python
    ```

5. Abra seu navegador e visite `http://localhost:5001` para ver a mensagem "Bem-Vindo ao Hello World Flask Python". Evite usar a porta 5000 no seu host ou computador pois outras aplicações podem estar rodando em paralelo utilizando a mesma porta.

---

<p align="center">
  <strong>🚀 Aplicações de Exemplo 🛡️</strong><br>
    <em>🐍 Python Flask com Docker</em>
</p>
