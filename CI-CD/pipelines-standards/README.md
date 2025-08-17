<p align="center">
  <img src="../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Sobre a pasta `pipelines`

Esta pasta contém arquivos e configurações relacionados aos pipelines de CI/CD do projeto. Aqui você encontrará scripts, definições de workflows e documentação sobre os processos automatizados de integração contínua e entrega contínua utilizados para garantir a qualidade e a entrega eficiente do software.

- **CI (Integração Contínua):** Automatiza testes e validações a cada alteração no código.
- **CD (Entrega Contínua):** Automatiza o deploy das aplicações em ambientes de homologação ou produção.

Consulte os arquivos desta pasta para detalhes sobre cada pipeline implementado.

## Cache de Dependências

Para otimizar os pipelines de CI/CD, é essencial implementar estratégias de cache para dependências e camadas Docker. Isso reduz o tempo de build e melhora a eficiência do processo.

O arquivo [cache.yaml](./cache/cache.yaml) contém as configurações necessárias para implementar o cache de dependências. 

## Segurança

O arquivo [gitleaks.yaml](./security/gitleaks.yaml) contém as regras de segurança para o GitLeaks, uma ferramenta que ajuda a identificar segredos expostos no código. É importante revisar e aplicar essas regras para garantir a segurança do repositório.

O arquivo [snyk.yaml](./security/snyk.yaml) contém as configurações para o Snyk, uma ferramenta de segurança que analisa vulnerabilidades em dependências e imagens Docker. Certifique-se de configurar corretamente o Snyk para monitorar e corrigir vulnerabilidades.

---

<p align="center">
  <strong>🚀 CI/CD e Automação 🛡️</strong><br>
    <em>📋 Pipeline Standards</em>
</p>

O arquivo [trivy.yaml](./security/trivy.yaml) contém as regras de segurança para o Trivy, uma ferramenta de varredura de vulnerabilidades em imagens Docker e sistemas de arquivos. É importante configurar o Trivy para garantir que as imagens utilizadas estejam livres de vulnerabilidades conhecidas.


## Build

O arquivo [build.yaml](./build/build.yaml) contém as definições do pipeline de build. Este pipeline é responsável por compilar o código, executar testes automatizados e gerar artefatos prontos para deploy e fazer o push para o repositório de artefatos.
