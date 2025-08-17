# Introdução

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/commitizen-tools/commitizen/pythonpackage.yml?label=python%20package&logo=github&logoColor=white&style=flat-square)](https://github.com/commitizen-tools/commitizen/actions)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=flat-square)](https://conventionalcommits.org)
[![PyPI Package latest release](https://img.shields.io/pypi/v/commitizen.svg?style=flat-square)](https://pypi.org/project/commitizen/)
[![PyPI Package download count (per month)](https://img.shields.io/pypi/dm/commitizen?style=flat-square)](https://pypi.org/project/commitizen/)
[![Supported versions](https://img.shields.io/pypi/pyversions/commitizen.svg?style=flat-square)](https://pypi.org/project/commitizen/)
[![Conda Version](https://img.shields.io/conda/vn/conda-forge/commitizen?style=flat-square)](https://anaconda.org/conda-forge/commitizen)
[![homebrew](https://img.shields.io/homebrew/v/commitizen?color=teal&style=flat-square)](https://formulae.brew.sh/formula/commitizen)
[![Codecov](https://img.shields.io/codecov/c/github/commitizen-tools/commitizen.svg?style=flat-square)](https://codecov.io/gh/commitizen-tools/commitizen)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?style=flat-square&logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

![Usando commitizen cli](https://commitizen-tools.github.io/commitizen/images/demo.gif)

---

**Documentação:** [https://commitizen-tools.github.io/commitizen/](https://commitizen-tools.github.io/commitizen/)

---

## Sobre

Commitizen é uma ferramenta de gerenciamento de versão projetada para equipes.

Commitizen assume que sua equipe usa uma forma padrão de regras de commit e, a partir dessa base, pode incrementar a versão do seu projeto, criar o changelog e atualizar arquivos.

Por padrão, commitizen usa [conventional commits](https://www.conventionalcommits.org), mas você pode criar seu próprio conjunto de regras e publicá-las.

Usar um conjunto padronizado de regras para escrever commits torna os commits mais fáceis de ler e impõe a escrita de commits descritivos.

### Funcionalidades

- Utilitário de linha de comando para criar commits com suas regras. Padrão: [Conventional commits](https://www.conventionalcommits.org)
- Incrementar versão automaticamente usando [versionamento semântico](https://semver.org/) baseado nos commits. [Leia mais](https://commitizen-tools.github.io/commitizen/commands/bump/)
- Gerar um changelog usando [Keep a changelog](https://keepachangelog.com/)
- Atualizar automaticamente os arquivos de versão do seu projeto
- Exibir informações sobre suas regras de commit (comandos: schema, example, info)
- Criar seu próprio conjunto de regras e publicá-las no pip. Leia mais sobre [Customização](https://commitizen-tools.github.io/commitizen/customization/)

## Requisitos

[Python](https://www.python.org/downloads/) `3.9+`

[Git](https://git-scm.com/downloads) `1.8.5.2+`

## Instalação

Instale commitizen em seu sistema usando `pipx` (Recomendado, [https://pypa.github.io/pipx/installation/](https://pypa.github.io/pipx/installation/)):

```bash
pipx ensurepath
pipx install commitizen
pipx upgrade commitizen
```

Instale commitizen usando `pip` com a flag `--user`:

```bash
pip install --user -U commitizen
```

### Projeto Python

Você pode adicioná-lo ao seu projeto local usando um dos seguintes métodos.

Com `pip`:

```bash
pip install -U commitizen
```

Com `conda`:

```bash
conda install -c conda-forge commitizen
```

Com Poetry >= 1.2.0:

```bash
poetry add commitizen --group dev
```

Com Poetry < 1.2.0:

```bash
poetry add commitizen --dev
```

### macOS

Via [homebrew](https://formulae.brew.sh/formula/commitizen):

```bash
brew install commitizen
```

## Uso

Na maioria das vezes, este é o único comando que você executará:

```bash
cz bump
```

Além disso, você pode usar commitizen para ajudá-lo na criação de commits:

```bash
cz commit
```

Leia mais na seção [Começando](https://commitizen-tools.github.io/commitizen/getting_started/).

### Ajuda

```bash
$ cz --help
uso: cz [-h] [--debug] [-n NAME] [-nr NO_RAISE] {init,commit,c,ls,example,info,schema,bump,changelog,ch,check,version} ...

Commitizen é uma ferramenta CLI para gerar commits convencionais.
Para mais informações sobre o tópico, acesse https://conventionalcommits.org/

argumentos opcionais:
  -h, --help            mostra esta mensagem de ajuda e sai
  --config              o caminho do arquivo de configuração
  --debug               usa modo debug
  -n NAME, --name NAME  usa o commitizen fornecido (padrão: cz_conventional_commits)
  -nr NO_RAISE, --no-raise NO_RAISE
                        códigos de erro separados por vírgula que não gerarão erro, ex: cz -nr 1,2,3 bump. Veja os códigos em https://commitizen-
                        tools.github.io/commitizen/exit_codes/

comandos:
  {init,commit,c,ls,example,info,schema,bump,changelog,ch,check,version}
    init                inicializa configuração do commitizen
    commit (c)          cria novo commit
    ls                  mostra commitizens disponíveis
    example             mostra exemplo de commit
    info                mostra informações sobre o cz
    schema              mostra esquema de commit
    bump                incrementa versão semântica baseada no log git
    changelog (ch)      gera changelog (note que ele sobrescreverá o arquivo existente)
    check               valida se uma mensagem de commit corresponde ao esquema do commitizen
    version             obtém a versão do commitizen instalado ou do projeto atual (padrão: commitizen instalado)
```

## Configurando autocompletar no bash

Ao usar bash como seu shell (há suporte limitado para zsh, fish e tcsh), Commitizen pode usar [argcomplete](https://kislyuk.github.io/argcomplete/) para autocompletar. Para isso, o argcomplete precisa estar ativado.

argcomplete é instalado quando você instala Commitizen, pois é uma dependência.

Se o Commitizen estiver instalado globalmente, a ativação global pode ser executada:

```bash
sudo activate-global-python-argcomplete
```

Para ativação permanente (mas não global) do Commitizen, use:

```bash
register-python-argcomplete cz >> ~/.bashrc
```

Para ativação única do argcomplete apenas para Commitizen, use:

```bash
eval "$(register-python-argcomplete cz)"
```

Para mais informações sobre ativação, visite o [site do argcomplete](https://kislyuk.github.io/argcomplete/).

## GitHub Actions

### Automatizando bump de versão com GitHub Actions

Você pode automatizar o processo de bump de versão usando GitHub Actions. Crie um arquivo `.github/workflows/bump.yml` no seu repositório:

```yaml
name: Bump version

on:
  push:
    branches: [ main ]

jobs:
  bump-version:
    if: "!startsWith(github.event.head_commit.message, 'bump:')"
    runs-on: ubuntu-latest
    name: "Bump version and create changelog with commitizen"
    steps:
    - name: Check out
      uses: actions/checkout@v4
      with:
        token: "${{ secrets.PERSONAL_ACCESS_TOKEN }}"
        fetch-depth: 0
    - name: Create bump and changelog
      uses: commitizen-tools/commitizen-action@master
      with:
        github_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
```

### Configuração necessária

1. **Personal Access Token**: Crie um Personal Access Token no GitHub com permissões de `repo` e adicione-o aos secrets do repositório como `PERSONAL_ACCESS_TOKEN`.

2. **Arquivo pyproject.toml**: Configure o commitizen no seu projeto:

```toml
[tool.commitizen]
name = "cz_conventional_commits"
version = "0.1.0"
tag_format = "v$major.$minor.$patch"
version_files = [
    "pyproject.toml:version"
]
```

### Como funciona

- O workflow é executado a cada push na branch `main`
- Verifica se não é um commit de bump (evita loops infinitos)
- Usa o commitizen para analisar os commits e determinar o tipo de bump
- Gera automaticamente o changelog
- Cria uma tag de versão
- Faz push das mudanças de volta para o repositório

Dessa forma, toda vez que você fizer merge de uma feature na branch principal, a versão será automaticamente incrementada baseada nos seus commits convencionais.