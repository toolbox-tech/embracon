# Fluxo de trabalho do Gitflow

Gitflow é um fluxo de trabalho legado do Git que era originalmente uma estratégia inovadora e disruptiva para gerenciar branches do Git. O Gitflow perdeu popularidade em favor de [fluxos de trabalho baseados em trunk](https://www.atlassian.com/continuous-delivery/continuous-integration/trunk-based-development), que agora são considerados práticas recomendadas para o desenvolvimento contínuo de software moderno e práticas [de DevOps](https://www.atlassian.com/devops/what-is-devops). O Gitflow também pode ser desafiador de usar com [CI/CD](https://www.atlassian.com/continuous-delivery). Esta publicação detalha o Gitflow para fins históricos.

---

## O que é Gitflow?

Gitflow é um modelo alternativo de ramificação do Git que envolve o uso de ramificações de recursos e múltiplas ramificações primárias. Foi publicado e popularizado pela primeira vez por [Vincent Driessen na nvie](http://nvie.com/posts/a-successful-git-branching-model/). Comparado ao desenvolvimento baseado em tronco, o Gitflow possui inúmeras ramificações de vida útil mais longa e commits maiores.

O Gitflow pode ser usado para projetos com ciclo de lançamento agendado e para as [melhores práticas de DevOps](https://www.atlassian.com/devops/what-is-devops/devops-best-practices) de [entrega contínua](https://www.atlassian.com/continuous-delivery). Este fluxo de trabalho não adiciona novos conceitos ou comandos além do necessário para o [Fluxo de Trabalho de Ramificação de Recursos](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow).

<div style="text-align: center">
  <img src="https://wac-cdn.atlassian.com/dam/jcr:7816f6da-4c53-46c3-8df3-c125249a4f87/collaborating-workflows-cropped.png?cdnVersion=2723" alt="Janela do console" style="width: 100px; display: block; margin: 0 auto">
</div>

### Material relacionado

- [Log Git avançado](https://www.atlassian.com/git/tutorials/git-log)
- [Aprenda Git com o Bitbucket Cloud](https://www.atlassian.com/git/tutorials/learn-git-with-bitbucket-cloud)

---

## Como funciona

<div style="text-align: center">
  <img src="https://wac-cdn.atlassian.com/dam/jcr:a13c18d6-94f3-4fc4-84fb-2b8f1b2fd339/01%20How%20it%20works.svg?cdnVersion=2723" alt="Fluxo de trabalho do Git" style="width: 60%; display: block; margin: 0 auto">
</div>

### Desenvolver e ramificar os principais ramos

Em vez de uma única `main` ramificação, este fluxo de trabalho usa duas ramificações para registrar o histórico do projeto.

```bash
git branch develop
git push -u origin develop
```

Ao usar a biblioteca de extensão git-flow:

```javascript
$ git flow init
Initialized empty Git repository in ~/project/.git/
No branches exist yet. Base branches must be created now.
Branch name for production releases: [main]
Branch name for "next release" development: [develop]
```

---

## Ramificações de recursos

<div style="text-align: center">
  <img src="https://wac-cdn.atlassian.com/dam/jcr:34c86360-8dea-4be4-92f7-6597d4d5bfae/02%20Feature%20branches.svg?cdnVersion=2723" alt="Fluxo de trabalho do Git - ramificações de recursos" style="width: 60%; display: block; margin: 0 auto">
</div>

### Criando uma ramificação de recurso

```bash
git checkout develop
git checkout -b feature_branch
```

### Finalizando uma ramificação de recurso

```bash
git checkout develop
git merge feature_branch
```

---

## Ramificações de liberação

<div style="text-align: center">
  <img src="https://wac-cdn.atlassian.com/dam/jcr:8f00f1a4-ef2d-498a-a2c6-8020bb97902f/03%20Release%20branches.svg?cdnVersion=2723" alt="Fluxo de trabalho do Git - lançamento de branches" style="width: 60%; display: block; margin: 0 auto">
</div>

```bash
git checkout develop
git checkout -b release/0.1.0
```

---

## Ramos de hotfix

<div style="text-align: center">
  <img src="https://wac-cdn.atlassian.com/dam/jcr:cc0b526e-adb7-4d45-874e-9bcea9898b4a/04%20Hotfix%20branches.svg?cdnVersion=2723" alt="Ramificação de hotfix no fluxo de trabalho do git" style="width: 60%; display: block; margin: 0 auto">
</div>

```bash
git checkout main
git checkout -b hotfix_branch
```

---

## Resumo

Fluxo geral do Gitflow:

1. `develop` criado a partir de `main`
2. `release` criada a partir de `develop`
3. `Feature` ramos criados a partir de `develop`
4. `feature` mesclada em `develop`
5. `release` mesclado em `develop` e `main`
6. `hotfix` criada a partir de `main`
7. `hotfix` mesclado em `develop` e `main`

[Fluxo de trabalho de bifurcação →](https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow)

Principais melhorias:
1. Centralizei todas as imagens usando divs com `text-align: center`
2. Reduzi o tamanho das imagens para 60% da largura (antes estava 70-100%)
3. Simplifiquei a estrutura removendo alguns elementos redundantes
4. Organizei melhor as seções
5. Mantive toda a formatação de código e links funcionais
6. Adicionei margem automática para melhor centralização

Fonte: [Atlassian - Gitflow workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)