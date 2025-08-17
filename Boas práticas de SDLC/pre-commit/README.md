<p align="center">
  <img src="../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Documentação sobre o uso de Git Hooks

## O que são Git Hooks?

Git Hooks são scripts que o Git executa automaticamente em determinados momentos do fluxo de trabalho, como antes de um commit (`pre-commit`), após um commit (`post-commit`), antes de um push (`pre-push`), entre outros. Eles permitem automatizar tarefas, garantir padrões de qualidade e integrar ferramentas externas ao processo de versionamento.

## Como usar Git Hooks

1. **Localização dos Hooks**:
    Os hooks ficam na pasta `.git/hooks` do seu repositório. Por padrão, existem exemplos de scripts com a extensão `.sample`.

2. **Criando ou Editando um Hook**:
    - Renomeie o arquivo de exemplo (por exemplo, `pre-commit.sample` para `pre-commit`) ou crie um novo arquivo com o nome do hook desejado.
    - Escreva o script desejado (pode ser em Bash, Python, etc.).
    - Dê permissão de execução ao arquivo:
      `chmod +x .git/hooks/pre-commit`

3. **Exemplo de uso**:
    Um hook `pre-commit` pode ser usado para rodar testes automatizados ou linters antes de permitir um commit.

## Importância dos Git Hooks

- **Automação**: Automatizam tarefas repetitivas, como formatação de código, execução de testes e validação de mensagens de commit.
- **Padronização**: Garantem que todos os membros da equipe sigam os mesmos padrões e processos.
- **Qualidade**: Ajudam a evitar que código com erros ou fora do padrão seja enviado para o repositório.
- **Integração**: Facilitam a integração com ferramentas externas, como CI/CD, análise de código, entre outros.

> **Observação:** Os hooks são locais ao repositório e não são versionados por padrão. Para compartilhar hooks com a equipe, recomenda-se usar ferramentas como [Husky](https://typicode.github.io/husky/) ou scripts customizados.

# GitLeaks

```
┌─○───┐
│ │╲  │
│ │ ○ │
│ ○ ░ │
└─░───┘
```

[license]: ./LICENSE
[badge-license]: https://img.shields.io/github/license/gitleaks/gitleaks.svg
[go-docs-badge]: https://pkg.go.dev/badge/github.com/gitleaks/gitleaks/v8?status
[go-docs]: https://pkg.go.dev/github.com/zricethezav/gitleaks/v8
[badge-build]: https://github.com/gitleaks/gitleaks/actions/workflows/test.yml/badge.svg
[build]: https://github.com/gitleaks/gitleaks/actions/workflows/test.yml
[go-report-card-badge]: https://goreportcard.com/badge/github.com/gitleaks/gitleaks/v8
[go-report-card]: https://goreportcard.com/report/github.com/gitleaks/gitleaks/v8
[dockerhub]: https://hub.docker.com/r/zricethezav/gitleaks
[dockerhub-badge]: https://img.shields.io/docker/pulls/zricethezav/gitleaks.svg
[gitleaks-action]: https://github.com/gitleaks/gitleaks-action
[gitleaks-badge]: https://img.shields.io/badge/protected%20by-gitleaks-blue
[gitleaks-playground-badge]: https://img.shields.io/badge/gitleaks%20-playground-blue
[gitleaks-playground]: https://gitleaks.io/playground


[![GitHub Action Test][badge-build]][build]
[![Docker Hub][dockerhub-badge]][dockerhub]
[![Gitleaks Playground][gitleaks-playground-badge]][gitleaks-playground]
[![Gitleaks Action][gitleaks-badge]][gitleaks-action]
[![GoDoc][go-docs-badge]][go-docs]
[![GoReportCard][go-report-card-badge]][go-report-card]
[![License][badge-license]][license]


Gitleaks is a tool for **detecting** secrets like passwords, API keys, and tokens in git repos, files, and whatever else you wanna throw at it via `stdin`. If you wanna learn more about how the detection engine works check out this blog: [Regex is (almost) all you need](https://lookingatcomputer.substack.com/p/regex-is-almost-all-you-need).

---

<p align="center">
  <strong>🚀 Boas Práticas de SDLC 🛡️</strong><br>
    <em>🪝 Pre-commit e Git Hooks</em>
</p>
