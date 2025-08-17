<p align="center">
  <img src="../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>


# 🚀 Commitizen - Guia Completo

*Transforme seus commits em uma obra de arte!*

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

</div>

---

## 📚 **Documentação Oficial**
🔗 **[https://commitizen-tools.github.io/commitizen/](https://commitizen-tools.github.io/commitizen/)**

---

## 🎯 **O que é o Commitizen?**

> 💡 **Commitizen é a ferramenta definitiva para equipes que levam versionamento a sério!**

O Commitizen revoluciona a forma como sua equipe gerencia versões e commits. Ele assume que você segue padrões de commit bem definidos e, a partir disso, automatiza todo o processo de:

- ✅ **Versionamento semântico**
- ✅ **Geração de changelogs**  
- ✅ **Atualização de arquivos de versão**

Por padrão, utiliza [**Conventional Commits**](https://www.conventionalcommits.org), mas você pode criar suas próprias regras personalizadas!

### 🌟 **Por que usar?**

**Padronização** torna commits mais legíveis e força a criação de mensagens descritivas que realmente importam!

---

## ⚡ **Funcionalidades Poderosas**

| Funcionalidade | Descrição |
|---|---|
| 🔧 **CLI Intuitivo** | Crie commits seguindo suas regras com facilidade |
| 🚀 **Auto-increment** | Versionamento semântico automático baseado em commits |
| 📋 **Changelog** | Geração automática usando [Keep a changelog](https://keepachangelog.com/) |
| 🔄 **Sync de Versões** | Atualiza automaticamente arquivos de versão do projeto |
| 📖 **Documentação** | Comandos para exibir regras (schema, example, info) |
| 🎨 **Customização** | Crie e publique seus próprios conjuntos de regras |

---

## 📋 **Requisitos do Sistema**

| Ferramenta | Versão Mínima |
|---|---|
| 🐍 **Python** | `3.9+` |
| 🌳 **Git** | `1.8.5.2+` |

---

## 📦 **Instalação Rápida**

### 🏆 **Método Recomendado - pipx**
```bash
pipx ensurepath
pipx install commitizen
pipx upgrade commitizen
```

### 🔧 **Instalação Global - pip**
```bash
pip install --user -U commitizen
```

### 🐍 **Para Projetos Python**

**Com pip:**
```bash
pip install -U commitizen
```

**Com conda:**
```bash
conda install -c conda-forge commitizen
```

**Com Poetry (>= 1.2.0):**
```bash
poetry add commitizen --group dev
```

**Com Poetry (< 1.2.0):**
```bash
poetry add commitizen --dev
```

### 🍎 **macOS - Homebrew**
```bash
brew install commitizen
```

---

## 🎮 **Como Usar**

### 🎯 **Comando Principal**
```bash
cz bump  # ✨ Mágica acontece aqui!
```

### 💬 **Criar Commits Padronizados**
```bash
cz commit  # 📝 Guia interativo para commits perfeitos
```

> 📖 **Quer saber mais?** Visite nossa seção [**Começando**](https://commitizen-tools.github.io/commitizen/getting_started/)

---

## 🆘 **Central de Ajuda**

<details>
<summary>🔍 <strong>Ver todos os comandos disponíveis</strong></summary>

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

</details>

---

## ⚙️ **Configurando Autocompletar no Bash**

> 💡 **Dica Pro:** Acelere seu workflow com autocompletar inteligente!

**Ativação Global:**
```bash
sudo activate-global-python-argcomplete
```

**Ativação Permanente (local):**
```bash
register-python-argcomplete cz >> ~/.bashrc
```

**Ativação Única:**
```bash
eval "$(register-python-argcomplete cz)"
```

📚 **Mais informações:** [Site do argcomplete](https://kislyuk.github.io/argcomplete/)

---

## 🤖 **Automação com GitHub Actions**

### 🔄 **Workflow Automático de Bump**

Crie o arquivo `.github/workflows/bump.yml`:

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

### ⚙️ **Configuração Essencial**

**1. 🔑 Personal Access Token**
- Crie um token com permissões `repo`
- Adicione como `PERSONAL_ACCESS_TOKEN` nos secrets

**2. 📄 Arquivo pyproject.toml**
```toml
[tool.commitizen]
name = "cz_conventional_commits"
version = "0.1.0"
tag_format = "v$major.$minor.$patch"
version_files = [
    "pyproject.toml:version"
]
```

### 🎯 **Como Funciona a Magia**

1. 🚀 **Trigger:** Push na branch `main`
2. 🔍 **Análise:** Verifica commits desde a última versão
3. 📊 **Decisão:** Determina tipo de bump (patch/minor/major)
4. 📝 **Geração:** Cria changelog automaticamente
5. 🏷️ **Tag:** Cria tag de versão
6. ⬆️ **Push:** Envia mudanças de volta ao repositório

> 🎉 **Resultado:** Versionamento 100% automatizado baseado em commits convencionais!

---

<p align="center">
  <strong>🚀 Boas Práticas de SDLC 🛡️</strong><br>
    <em>📝 Commitizen</em>
</p>