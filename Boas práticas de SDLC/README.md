# O que é o Ciclo de Vida do Desenvolvimento de Software (SDLC - Software Development Lifecycle)?

O Ciclo de Vida do Desenvolvimento de Software é um conjunto de práticas que compõem uma estrutura para padronizar a construção de aplicações de software. O SDLC define as tarefas a serem realizadas em cada etapa do desenvolvimento de software. Essa metodologia visa melhorar a qualidade do software e do processo de desenvolvimento, superando as expectativas dos clientes e cumprindo prazos e estimativas de custo.
Por exemplo, com o aumento da demanda dos clientes e do poder computacional, os custos de software aumentam, assim como a dependência de desenvolvedores. O SDLC fornece uma maneira de medir e aprimorar o processo de desenvolvimento, oferecendo insights e análises de cada etapa, maximizando a eficiência e reduzindo os custos.

## Como o SDLC funciona?

O Ciclo de Vida do Desenvolvimento de Software fornece a orientação necessária para criar uma aplicação de software. Ele faz isso dividindo as tarefas em fases que formam o SDLC. Padronizar as tarefas dentro de cada fase aumenta a eficiência do processo de desenvolvimento. Cada fase é dividida em tarefas menores que podem ser medidas e monitoradas. Isso permite acompanhar o andamento dos projetos para garantir que permaneçam no cronograma.
O objetivo do SDLC é estabelecer processos repetíveis e resultados previsíveis dos quais projetos futuros possam se beneficiar. As fases do SDLC geralmente são divididas entre 6 a 8 etapas.

As fases são:

- Planejamento: a fase de planejamento abrange todos os aspectos da gestão de projetos e produtos, incluindo alocação de recursos, cronograma do projeto, estimativa de custos, entre outros.

- Definição de Requisitos: considerada parte do planejamento, essa etapa determina o que a aplicação deve fazer e quais são os seus requisitos. Por exemplo, um aplicativo de rede social precisaria da capacidade de se conectar com amigos.

- Design e Prototipagem: nesta fase se define como o software funcionará, qual linguagem de programação será usada, como os componentes irão se comunicar entre si, arquitetura, etc.

- Desenvolvimento de Software: envolve construir o programa, escrever o código e a documentação.

- Testes: nesta fase, garante-se que os componentes funcionem corretamente e possam interagir entre si. Por exemplo, verifica-se se cada função está funcionando corretamente, se as diferentes partes do aplicativo operam juntas de forma integrada e se o desempenho está adequado, sem travamentos.

- Implantação (Deployment): nesta etapa, o aplicativo ou projeto é disponibilizado para os usuários.

- Operações e Manutenção: aqui os engenheiros respondem a problemas na aplicação ou a falhas relatadas pelos usuários, e às vezes planejam funcionalidades adicionais para versões futuras.

As empresas podem optar por reorganizar essas fases, dividindo ou unificando etapas, resultando em 6 a 8 fases no total. Por exemplo, é possível mesclar a fase de testes com a de desenvolvimento em cenários onde a segurança é incorporada em cada etapa do desenvolvimento, já que os desenvolvedores corrigem falhas durante os testes.

Fonte: [Try Hack Me - What is Software Development Lifecycle (SDLC)?](https://tryhackme.com/room/sdlc)

# Quais são as melhores práticas de controle de versão do Git?

## A importância das melhores práticas de controle de versão do Git

As melhores práticas de controle de versão do Git ajudam as equipes de desenvolvimento de software a atender às dinâmicas demandas de alterações do setor, juntamente com a crescente necessidade de novos recursos por parte dos clientes. A velocidade com que as equipes precisam trabalhar pode levar a silos, o que diminui a agilidade. As equipes de desenvolvimento de software recorrem ao controle de versão para simplificar a colaboração e eliminar os silos de informações.

Com as melhores práticas do Git, as equipes podem coordenar todas as alterações em um projeto de software e usar o branching rápido para ajudar as equipes a colaborar e compartilhar feedback rapidamente, levando a alterações imediatas e aplicáveis. O Git, como base fundamental do desenvolvimento de software moderno, oferece um conjunto de ferramentas e recursos potentes criados para otimizar os ciclos de desenvolvimento, melhorar a qualidade de código e promover a colaboração entre os membros da equipe.

## Faça pequenas alterações incrementais

Escreva a menor quantidade de código possível para resolver um problema. Depois de identificar um problema ou melhoria, a maneira ideal de experimentar algo novo e não testado é dividir a atualização em pequenas partes que possam ser fácil e rapidamente testadas com o usuário final para provar a validade da solução proposta e reverter caso não funcione, sem prejudicar toda a nova funcionalidade.

Fazer o commit de código em pequenos lotes diminui a probabilidade de conflitos de integração, porque quanto mais tempo um branch permanece separado do branch principal ou da linha de código, mais tempo outros desenvolvedores passam fazendo merge de alterações no branch principal, aumentando a probabilidade de conflitos de integração durante o merge. Pequenos commits frequentes resolvem esse problema. As alterações incrementais também ajudam os membros da equipe a reverter facilmente se ocorrerem conflitos de merge, especialmente quando essas alterações foram devidamente documentadas na forma de mensagens descritivas de commit.

## Mantenha os commits atômicos

Relacionados a fazer pequenas alterações, os commits atômicos são uma unidade de trabalho, envolvendo apenas uma tarefa ou uma correção (por exemplo, atualização, correção de bug, refatoração). Commits atômicos tornam as revisões de código mais rápidas e as reversões mais fáceis, pois podem ser aplicados ou revertidos sem efeitos secundários indesejados.

O objetivo dos commits atômicos não é criar centenas de commits, mas agrupá-los por contexto. Por exemplo, se um desenvolvedor precisar refatorar o código e adicionar um novo recurso, ele deverá criar dois commits separados em vez de criar um commit monolítico, que inclui alterações com finalidades diferentes.

## Desenvolva usando branches

Com os branches, as equipes de desenvolvimento de software podem fazer alterações sem afetar a linha de código principal. O histórico de execução das alterações é rastreado em um branch e, quando o código está pronto, ele é mesclado no branch principal.

O branching organiza o desenvolvimento e separa o trabalho em andamento do código estável e testado no branch principal. O desenvolvimento em branches garante que bugs e vulnerabilidades não entrem no código-fonte e afetem os usuários, pois testá-los e encontrá-los em um branch é mais fácil.

## Escreva mensagens de commit descritivas

As mensagens de commit descritivas são tão importantes quanto uma alteração. Escreva mensagens de commit descritivas começando com um verbo no tempo presente no modo imperativo para indicar o propósito de cada commit de maneira clara e concisa. Cada commit deve ter apenas um propósito explicado em detalhes na mensagem do commit. A documentação do Git dá orientações sobre como escrever mensagens de commit descritivas.

Descreva suas alterações no modo imperativo, por exemplo, "faça xyzzy do frotz" em vez de "[Este patch] faz xyzzy do frotz" ou "[Eu] mudei o xyzzy para fazer frotz", como se você estivesse dando comandos ao codebase para alterar o comportamento dele. Tente garantir que sua explicação possa ser entendida sem recursos externos. Em vez de disponibilizar um URL para um arquivo de lista de discussão, resuma os pontos relevantes da conversa.

Escrever mensagens de commit dessa forma força as equipes de software a entenderem o valor que uma adição ou correção traz à linha de código existente. Se as equipes acharem impossível encontrar o valor e descrevê-lo, talvez valha a pena reavaliar as motivações por trás do commit. Sempre há tempo para fazer o commit depois, pois as alterações são armazenadas e há uniformidade nos commits.

## Obtenha feedback por meio de revisões de código

Solicitar feedback de outras pessoas é uma excelente maneira de garantir a qualidade do código. As revisões de código são um método eficaz para identificar se uma proposta resolve um problema da maneira mais eficiente possível. Pedir a membros de outras equipes que revisem o código é importante, porque algumas áreas do codebase podem incluir conhecimento de domínio específico ou até mesmo implicações de segurança além das atribuições do colaborador individual.

Incluir um stakeholder específico na conversa é uma boa prática e cria um ciclo de feedback mais rápido, evitando problemas posteriores no ciclo de vida do desenvolvimento de software. Isso é especialmente importante para desenvolvedores juniores, pois, por meio da revisão de código, desenvolvedores sêniores podem transferir conhecimento de uma maneira muito prática e direta.

## Identifique uma estratégia de gerenciamento de branches

As equipes de desenvolvimento de software incluem profissionais com experiências e formações diversas, o que pode causar fluxos de trabalho conflitantes. Determinar uma única estratégia de gerenciamento de branches é a solução para evitar uma experiência de desenvolvimento caótica.

Embora existam várias abordagens para o desenvolvimento, as mais comuns são:

- Fluxo de trabalho centralizado: as equipes usam apenas um único repositório e fazem o commit diretamente no branch principal.

- Gerenciamento de branches de recursos: as equipes usam um novo branch para cada recurso e não fazem commit diretamente no branch principal.

- [GitFlow](./gitflow/README.md): uma versão extrema de gerenciamento de branches de recursos, na qual o desenvolvimento ocorre no branch de desenvolvimento, passa para um branch de lançamento e é mesclado no branch principal.

- Gerenciamento de branches pessoais: semelhante ao gerenciamento de branches de recursos, mas em vez de desenvolver em um branch por recurso, o desenvolvimento é feito por cada desenvolvedor em seu próprio branch. Cada usuário faz merge no branch principal quando conclui seu trabalho.

Muitas equipes decidem seguir um fluxo de trabalho estabelecido, mas outras criam uma abordagem personalizada com base em necessidades específicas. Independentemente da estratégia, é importante comunicar a decisão e a logística do fluxo de trabalho aos membros da equipe e oferecer treinamento se a abordagem for nova para alguns deles.

## Conclusão

A adoção das melhores práticas de controle de versão do Git é crucial para as equipes de desenvolvimento de software, permitindo que elas utilizem recursos e ferramentas incríveis que melhoram os fluxos de trabalho de desenvolvimento e o gerenciamento do histórico de versões. Isso garante a colaboração eficiente entre os membros da equipe, agiliza o processo de revisão e protege a integridade de código do software. A integração de sistemas de controle de versão no ciclo de desenvolvimento tornou-se um requisito fundamental.

Os benefícios do controle de versão são inegáveis, oferecendo um roteiro de sucesso para empresas que desejam prosperar no cenário competitivo do desenvolvimento de software. Ao adotar essas melhores práticas, as equipes podem preparar o terreno para crescimento e inovação futuros.

Fonte: [GitLab - Quais são as melhores práticas de controle de versão do Git?](https://about.gitlab.com/pt-br/topics/version-control/version-control-best-practices/)

# [Trunk-based](./trunk-based/README.md)

# [Gitflow](./gitflow/README.md)

# Boas Práticas para SDLC (Software Development Life Cycle)

## 1. Pre-commit e Commitizen
Uso do [Pre-commit](./pre-commit/README.md) para automatizar validações de código antes do commit, usando o Gitleaks para detectar segredos e o Commitizen para padronizar mensagens de commit.

## 2. Padrão de Commits com Commitizen
### Ferramenta
- Uso do [Commitizen](./commitizen/README.md) para padronizar mensagens de commit via CLI interativa.

### Fluxo de Trabalho
- Substitua `git commit -m "..."` por:
    ```bash
    git add . && cz commit
    ```
- **Tipos de commit obrigatórios**:
    - `fix`: Correção de bug. Correlaciona-se com PATCH no SemVer.
    - `feat`: Nova funcionalidade. Correlaciona-se com MINOR no SemVer.
    - `docs`: Alterações apenas na documentação.
    - `style`: Alterações que não afetam o significado do código (espaços em branco, formatação, ponto e vírgula ausente, etc.).
    - `refactor`: Alteração de código que não corrige um bug nem adiciona uma funcionalidade.
    - `perf`: Alteração de código que melhora o desempenho.
    - `test`: Adição ou correção de testes existentes.
    - `build`: Alterações que afetam o sistema de build ou dependências externas (ex.: pip, docker, npm).
    - `ci`: Alterações nos arquivos de configuração ou scripts de CI (ex.: GitLabCI).

---

## 3. Padrão de Política de Pull Request (PR)
### Requisitos Mínimos
- **Título**: Descritivo (ex: `[FEAT] Login com OAuth`).
- **Descrição**: Contexto, motivação e testes realizados.
- **Links**: Relacione à issue (ex: `Resolve #123`).

### Revisão de Código
- **Aprovações**: Mínimo de 1 reviewer (2 para projetos críticos).
- **Checklist**:
    - [ ] Testes passando.
    - [ ] Documentação atualizada.
    - [ ] Impacto em performance avaliado.

### Automação
- Use **GitHub Actions/GitLab CI** para:
    - Rodar testes e linters.

---

## 4. Padrão de Branches e Commits
### Estratégia de Branching
- **[GitFlow](./gitflow/README.md)** (para releases planejadas) ou **Trunk-Based** (para CI/CD).
- **Nomes de branches**:
    - `feat/oauth-support` (novas funcionalidades).
    - `fix/checkout-race` (correções).

### Convenção de Commits
- Exemplo:
    ```bash
    feat(auth): add OAuth2 support
    fix(checkout): resolve race condition
    ```

---

## 5. Treinamento em SCM (GitFlow vs. Trunk-Based)
### GitFlow
- **Branches**: `main`, `develop`, `feature/*`, `release/*`, `hotfix/*`.
- **Uso**: Projetos com versões estáveis (ex: enterprise).

### Trunk-Based
- **Branches**: `main` (sempre deployável) + feature flags.
- **Uso**: Times ágeis com deploys diários.

### Workshop
- Práticas de `rebase`, `cherry-pick` e resolução de conflitos.

---

## 6. Linter e Code Quality
### Ferramentas
- **[SonarQube](./sonarqube_codesense/README.md)**: Análise estática e cobertura de testes.
- **[CodeScene](./sonarqube_codesense/README.md)**: Análise de hotspots e colaboração.
- **Linters**:
    - ESLint/Prettier (JavaScript).
    - Pylint (Python).
- **Validação**:
    - Bloquear merge se:
        - Cobertura de testes < 80%.
        - Critical issues no Sonar.

---

## 7. API Design (Swagger/Stoplight)
### Documentação
- **[Swagger/OpenAPI](./swagger_stoplight/README.md)**: Especificação contratual.
- **[Stoplight](./swagger_stoplight/README.md)**: Design colaborativo.
- **Padrões**:
    - Versionamento (`/v1/users`).
    - Exemplos de payloads.

---

## 8. Documentação e Treinamento
### Arquitetura
- **Diagramas**: C4 Model ou UML (usando Draw.io).
- **ADRs**: Registro de decisões técnicas.

### Onboarding
- Wiki com:
    - Guia de setup.
    - Fluxo de deploy.

---

## 9. Políticas de Segurança no GitHub
### Mínimo Recomendado
- **Branch Protection**:
    - Bloquear `force push` em `main`.
    - Exigir 2FA para todos os devs.
- **Dependências**:
    - Scan com Dependabot.

---

## Fluxo Completo SDLC
![Fluxo Completo do SDLC](../img/SDLC.png)


<p align="center">
  <img src="../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# 📋 Boas Práticas de SDLC - Embracon Toolbox

## 🎯 Visão Geral

Este diretório contém um **conjunto abrangente de melhores práticas** para o **Software Development Life Cycle (SDLC)** adotado pela Embracon. Nossa abordagem integra metodologias modernas de desenvolvimento, controle de versão, qualidade de código e automação, garantindo entregas consistentes e de alta qualidade.

## 🏗️ Arquitetura do SDLC Embracon

```mermaid
graph TB
    subgraph "📋 Planejamento"
        PLAN[Product Planning]
        REQ[Requirements Definition]
        ARCH[Architecture Design]
    end
    
    subgraph "💻 Desenvolvimento"
        BRANCH[Branch Strategy]
        CODE[Coding Standards]
        COMMIT[Commit Conventions]
        PR[Pull Requests]
    end
    
    subgraph "🔍 Qualidade"
        PRECOMMIT[Pre-commit Hooks]
        LINT[Code Linting]
        SONAR[SonarQube Analysis]
        REVIEW[Code Review]
    end
    
    subgraph "🚀 Integração"
        CI[Continuous Integration]
        TEST[Automated Testing]
        BUILD[Build & Package]
        SECURITY[Security Scan]
    end
    
    subgraph "📦 Entrega"
        CD[Continuous Deployment]
        RELEASE[Release Management]
        MONITOR[Monitoring]
        FEEDBACK[Feedback Loop]
    end

    %% Flow connections
    PLAN --> REQ
    REQ --> ARCH
    ARCH --> BRANCH
    
    BRANCH --> CODE
    CODE --> COMMIT
    COMMIT --> PRECOMMIT
    PRECOMMIT --> LINT
    
    LINT --> PR
    PR --> REVIEW
    REVIEW --> SONAR
    SONAR --> CI
    
    CI --> TEST
    TEST --> BUILD
    BUILD --> SECURITY
    SECURITY --> CD
    
    CD --> RELEASE
    RELEASE --> MONITOR
    MONITOR --> FEEDBACK
    FEEDBACK --> PLAN

    %% Styling
    classDef planning fill:#e1f5fe,stroke:#0277bd,stroke-width:2px,color:#000
    classDef development fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#000
    classDef quality fill:#fff3e0,stroke:#ef6c00,stroke-width:2px,color:#000
    classDef integration fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px,color:#000
    classDef delivery fill:#fce4ec,stroke:#c2185b,stroke-width:2px,color:#000

    class PLAN,REQ,ARCH planning
    class BRANCH,CODE,COMMIT,PR development
    class PRECOMMIT,LINT,SONAR,REVIEW quality
    class CI,TEST,BUILD,SECURITY integration
    class CD,RELEASE,MONITOR,FEEDBACK delivery
```

## 📁 Estrutura e Componentes

### 📂 **Componentes do SDLC Embracon**

| Componente | Propósito | Ferramenta/Prática |
|------------|-----------|-------------------|
| **[Commitizen](./commitizen/)** | Padronização de commits | Conventional Commits + CLI |
| **[GitFlow](./gitflow/)** | Estratégia de branching | Git branching model |
| **[Pre-commit](./pre-commit/)** | Validação automática | Pre-commit hooks + Gitleaks |
| **[SonarQube](./sonarqube_codesense/)** | Análise de código | SonarQube + CodeScene |
| **[Swagger/Stoplight](./swagger_stoplight/)** | Design de APIs | OpenAPI + Stoplight Studio |
| **[Trunk-based](./trunk-based/)** | Desenvolvimento ágil | Trunk-based development |

---

## 🔄 O que é SDLC (Software Development Life Cycle)?

O **Ciclo de Vida do Desenvolvimento de Software (SDLC)** é um framework estruturado que define processos padronizados para construção de aplicações de software. Na Embracon, o SDLC é fundamental para:

- ✅ **Padronização** de processos entre equipes
- ✅ **Qualidade** consistente de entregáveis  
- ✅ **Previsibilidade** de cronogramas e custos
- ✅ **Escalabilidade** de operações de desenvolvimento
- ✅ **Redução** de riscos e retrabalho

### **🎯 Benefícios do SDLC Estruturado:**

```mermaid
mindmap
  root((SDLC Benefits))
    Qualidade
      Código consistente
      Menos bugs
      Performance otimizada
    Eficiência
      Processos padronizados
      Automação máxima
      Feedback rápido
    Colaboração
      Comunicação clara
      Responsabilidades definidas
      Knowledge sharing
    Manutenibilidade
      Documentação atualizada
      Código legível
      Arquitetura limpa
```

### **📋 Fases do SDLC Embracon:**

#### **1️⃣ Planejamento e Análise**
- **Product Planning**: Definição de roadmap e features
- **Requirements**: Levantamento de requisitos funcionais/não-funcionais
- **Architecture**: Design de arquitetura e tecnologias

#### **2️⃣ Design e Prototipagem**
- **System Design**: Arquitetura de sistemas e componentes
- **API Design**: Especificação OpenAPI/Swagger
- **UI/UX Design**: Protótipos e mockups

#### **3️⃣ Desenvolvimento**
- **Coding Standards**: Padrões de codificação
- **Version Control**: Git com estratégias de branching
- **Code Review**: Revisão colaborativa de código

#### **4️⃣ Testes e Qualidade**
- **Unit Testing**: Testes unitários automatizados
- **Integration Testing**: Testes de integração
- **Security Testing**: Análise de vulnerabilidades

#### **5️⃣ Deploy e Entrega**
- **CI/CD Pipelines**: Automação de build/deploy
- **Release Management**: Gestão de versões
- **Monitoring**: Observabilidade em produção

#### **6️⃣ Manutenção e Evolução**
- **Bug Fixes**: Correções e hotfixes
- **Feature Updates**: Novas funcionalidades
- **Performance Optimization**: Melhorias contínuas

---

## 🌿 Estratégias de Branching

### **📊 Comparação de Estratégias:**

| Aspecto | [GitFlow](./gitflow/) | [Trunk-based](./trunk-based/) |
|---------|-------|-------------|
| **Complexidade** | Alta | Baixa |
| **Branches** | Múltiplos (main, develop, feature, release, hotfix) | Mínimos (main + short-lived features) |
| **Deploy Frequency** | Releases planejadas | Deploy contínuo |
| **Team Size** | Grande (10+ devs) | Pequeno/Médio (2-10 devs) |
| **Release Cycle** | Semanal/Mensal | Diário/Contínuo |
| **Risk Level** | Baixo | Médio |
| **CI/CD Integration** | Complexa | Simples |
| **Rollback** | Fácil | Feature flags |

### **🎯 Quando Usar Cada Estratégia:**

#### **GitFlow - Indicado para:**
- ✅ Produtos com releases planejadas
- ✅ Equipes grandes (10+ desenvolvedores)
- ✅ Ambientes enterprise com QA dedicado
- ✅ Produtos que requerem releases estáveis

#### **Trunk-based - Indicado para:**
- ✅ Desenvolvimento ágil com deploys frequentes
- ✅ Equipes pequenas/médias (2-10 desenvolvedores)
- ✅ Produtos web com feedback rápido
- ✅ Cultura DevOps madura

---

## 📝 Padrões de Commit e Mensagens

### **🔧 Commitizen Integration**

Na Embracon, utilizamos **[Commitizen](./commitizen/)** para padronizar commits seguindo **Conventional Commits**:

```bash
# Ao invés de:
git commit -m "fix login bug"

# Use:
git add . && cz commit
# Isso abrirá uma interface interativa para criar commits padronizados
```

### **📋 Tipos de Commit Obrigatórios:**

| Tipo | Descrição | SemVer Impact | Exemplo |
|------|-----------|---------------|---------|
| `feat` | Nova funcionalidade | MINOR | `feat(auth): add OAuth2 support` |
| `fix` | Correção de bug | PATCH | `fix(api): resolve timeout in user service` |
| `docs` | Documentação | - | `docs(readme): update setup instructions` |
| `style` | Formatação de código | - | `style(lint): fix eslint warnings` |
| `refactor` | Refatoração | - | `refactor(utils): simplify date helpers` |
| `perf` | Melhoria de performance | PATCH | `perf(db): optimize user queries` |
| `test` | Adição/correção testes | - | `test(auth): add integration tests` |
| `build` | Sistema de build | - | `build(docker): update node base image` |
| `ci` | Configuração CI/CD | - | `ci(github): add security scan workflow` |

### **✅ Commits Atômicos e Incrementais:**

#### **Boas Práticas:**
```bash
# ✅ BOM: Commit atômico
feat(auth): add user registration endpoint

# ✅ BOM: Pequenas alterações incrementais  
fix(validation): handle edge case in email format

# ❌ RUIM: Commit monolítico
feat: add user management, fix login bug, update docs, refactor utils
```

#### **Mensagens Descritivas:**
```bash
# ✅ BOM: Imperativo, claro, contextual
feat(payment): integrate Stripe payment gateway

- Add Stripe SDK configuration
- Implement payment processing service  
- Add webhook handlers for payment events
- Update API documentation

# ❌ RUIM: Vago, não descriptivo
update payment stuff
```

---

## 🔍 Controle de Qualidade e Code Review

### **🛡️ Pre-commit Hooks com [Pre-commit](./pre-commit/)**

Implementação de validação automática antes de cada commit:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/commitizen-tools/commitizen
    rev: v1.17.0
    hooks:
      - id: commitizen
        stages: [commit-msg]
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.24.2
    hooks:
      - id: gitleaks
```

#### **🎯 Benefícios dos Pre-commit Hooks:**
- ✅ **Detecção precoce** de secrets e credenciais
- ✅ **Formatação automática** de código
- ✅ **Padronização** entre desenvolvedores
- ✅ **Prevenção** de problemas em produção

### **📋 Padrão de Pull Requests (PR)**

#### **📝 Template de PR:**

```markdown
## 📋 Descrição
Breve descrição das mudanças implementadas.

## 🎯 Motivação e Contexto
Por que essas mudanças são necessárias? Qual problema resolve?

## 🧪 Tipos de Mudanças
- [ ] Bug fix (mudança que corrige um problema)
- [ ] Nova feature (mudança que adiciona funcionalidade)
- [ ] Breaking change (mudança que quebra compatibilidade)
- [ ] Documentação (mudança apenas em documentação)

## ✅ Checklist
- [ ] Meu código segue o style guide do projeto
- [ ] Revisei meu próprio código
- [ ] Comentei o código em partes difíceis de entender
- [ ] Adicionei testes para minhas mudanças
- [ ] Todos os testes passam localmente
- [ ] Atualizei a documentação

## 🔗 Issues Relacionadas
Resolve #123
Relacionado a #456
```

#### **👥 Processo de Revisão:**

| Projeto | Mín. Reviewers | Requisitos |
|---------|----------------|------------|
| **Crítico** | 2 | Testes + Docs + Security scan |
| **Normal** | 1 | Testes + Lint |
| **Docs** | 1 | Lint |

### **⚙️ Automação de Quality Gates:**

```yaml
# GitHub Actions - Quality Gate
name: Quality Gate
on: [pull_request]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run linters
        run: |
          npm run lint
          npm run test:coverage
      - name: SonarQube Scan
        run: sonar-scanner
      - name: Security Scan
        run: npm audit
```

---

## 📊 Análise de Código e Métricas

### **🔍 SonarQube + CodeScene Integration**

Integração com **[SonarQube](./sonarqube_codesense/)** para análise contínua:

#### **📈 Métricas Obrigatórias:**
| Métrica | Threshold | Ação se Falhar |
|---------|-----------|----------------|
| **Cobertura de Testes** | ≥ 80% | Bloquear merge |
| **Duplicação de Código** | ≤ 3% | Warning |
| **Complexidade Ciclomática** | ≤ 10 | Code review obrigatório |
| **Vulnerabilidades** | 0 Critical | Bloquear merge |
| **Code Smells** | ≤ 5 Major | Warning |

#### **🎯 Quality Profiles por Linguagem:**

```yaml
# Java
sonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
sonar.java.pmd.reportPaths=target/pmd.xml
sonar.junit.reportPaths=target/surefire-reports

# JavaScript/TypeScript  
sonar.typescript.lcov.reportPaths=coverage/lcov.info
sonar.eslint.reportPaths=eslint-report.json

# Python
sonar.python.coverage.reportPaths=coverage.xml
sonar.python.xunit.reportPath=test-results.xml
```

### **🧠 CodeScene - Análise Comportamental:**

- **Hotspots**: Arquivos com alta mudança + complexidade
- **Knowledge Distribution**: Distribuição de conhecimento no time
- **Coupling**: Análise de acoplamento entre módulos
- **Technical Debt**: Estimativa de débito técnico

---

## 🎨 Design e Documentação de APIs

### **📖 Swagger/OpenAPI com [Stoplight](./swagger_stoplight/)**

#### **🏗️ Design-First Approach:**

```yaml
# openapi.yaml
openapi: 3.0.3
info:
  title: Embracon API
  version: 1.0.0
  description: API para gestão de contratos

servers:
  - url: https://api.embracon.com.br/v1
    description: Produção
  - url: https://api-dev.embracon.com.br/v1
    description: Desenvolvimento

paths:
  /contracts:
    get:
      summary: Listar contratos
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: Lista de contratos
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ContractList'
```

#### **📋 Padrões de API:**

| Padrão | Implementação | Exemplo |
|--------|---------------|---------|
| **Versionamento** | URL Path | `/v1/users`, `/v2/users` |
| **Paginação** | Query params | `?page=1&limit=20` |
| **Filtros** | Query params | `?status=active&type=premium` |
| **Ordenação** | Query params | `?sort=created_at&order=desc` |
| **Status Codes** | HTTP padrão | `200`, `201`, `400`, `404`, `500` |

### **🔄 Documentação Viva:**

```bash
# Geração automática de docs
swagger-codegen generate -i openapi.yaml -l html2 -o docs/

# Validação de contratos
postman-newman run api-tests.json --environment prod.env

# Mock server para desenvolvimento
stoplight prism mock openapi.yaml
```

---

## 🛡️ Segurança e Compliance

### **🔐 Security Scanning Pipeline:**

```yaml
name: Security Scan
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Secret Detection
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          
      - name: Dependency Check
        run: |
          npm audit --audit-level high
          npm run deps:check
          
      - name: SAST Scan
        uses: github/codeql-action/analyze@v2
        
      - name: Container Scan
        run: |
          docker build -t app:latest .
          trivy image app:latest
```

### **📋 Políticas de Branch Protection:**

#### **Branch `main`:**
- ✅ Require PR before merge
- ✅ Require status checks (CI/CD)
- ✅ Require up-to-date branches
- ✅ Restrict force pushes
- ✅ Require 2FA for admin access

#### **Branch `develop`:**
- ✅ Require PR before merge
- ✅ Require status checks
- ⚠️ Allow force pushes (admin only)

### **🔍 Compliance e Auditoria:**

| Aspecto | Ferramenta | Frequência |
|---------|------------|------------|
| **Secrets Scanning** | GitLeaks + TruffleHog | Todo commit |
| **Dependency Audit** | npm audit + Dependabot | Semanal |
| **License Compliance** | FOSSA | Mensal |
| **Security Review** | Manual + SAST | Por release |

---

## 🎓 Treinamento e Onboarding

### **📚 Programa de Capacitação SDLC:**

#### **Módulo 1: Fundamentos**
- Git básico e avançado
- Conventional Commits
- Code review best practices

#### **Módulo 2: Ferramentas**
- Setup de desenvolvimento local
- Pre-commit hooks
- IDE configuration

#### **Módulo 3: Qualidade**
- Testing strategies
- SonarQube analysis
- Security awareness

#### **Módulo 4: CI/CD**
- Pipeline configuration
- Deployment strategies
- Monitoring e observability

### **🏆 Certificação Interna:**

```mermaid
graph LR
    A[Desenvolidor Iniciante] --> B[Git + Commits]
    B --> C[Code Review]
    C --> D[Testing]
    D --> E[CI/CD]
    E --> F[Sênior Certified]
    
    B1[Workshop 1: Git Flow] --> B
    C1[Workshop 2: PR Reviews] --> C  
    D1[Workshop 3: TDD] --> D
    E1[Workshop 4: DevOps] --> E
```

---

## 📊 Métricas e KPIs do SDLC

### **📈 Dashboards de Acompanhamento:**

#### **Métricas de Velocidade:**
- **Lead Time**: Tempo de ideia → produção
- **Cycle Time**: Tempo de commit → deploy
- **Deployment Frequency**: Frequência de deploys
- **MTTR**: Mean Time To Recovery

#### **Métricas de Qualidade:**
- **Bug Escape Rate**: % bugs que chegam em produção
- **Test Coverage**: Cobertura de testes
- **Code Review Coverage**: % código revisado
- **Technical Debt Ratio**: Ratio de débito técnico

#### **Métricas de Colaboração:**
- **PR Review Time**: Tempo médio de review
- **Knowledge Distribution**: Distribuição de conhecimento
- **Bus Factor**: Fator de dependência de pessoas
- **Team Velocity**: Velocidade da equipe

### **🎯 Objetivos e Metas 2025:**

| KPI | Meta Q1 | Meta Q2 | Meta Q3 | Meta Q4 |
|-----|---------|---------|---------|---------|
| **Deploy Frequency** | 2x/semana | 1x/dia | 2x/dia | 3x/dia |
| **Lead Time** | 5 dias | 3 dias | 2 dias | 1 dia |
| **Test Coverage** | 70% | 75% | 80% | 85% |
| **MTTR** | 4h | 2h | 1h | 30min |

---

## 🚀 Implementação e Roadmap

### **📅 Cronograma de Implementação:**

#### **Fase 1: Fundação (Q1 2025)**
- ✅ Setup de Commitizen
- ✅ Configuração Pre-commit hooks
- ✅ Branch protection policies
- 🔄 Treinamento em Git practices

#### **Fase 2: Qualidade (Q2 2025)**
- 🔄 SonarQube integration
- 📋 PR template padronização
- 📋 Code review training
- 📋 Security scanning setup

#### **Fase 3: Automação (Q3 2025)**
- 📋 CI/CD pipelines optimization
- 📋 Automated testing integration
- 📋 Deployment automation
- 📋 Monitoring dashboards

#### **Fase 4: Excelência (Q4 2025)**
- 📋 Advanced metrics collection
- 📋 Predictive analytics
- 📋 Continuous improvement
- 📋 Innovation practices

### **🎯 Quick Start para Novos Projetos:**

```bash
# 1. Setup inicial do projeto
git clone <repo-url>
cd <project>

# 2. Install development tools
npm install -g commitizen @commitlint/cli
pip install pre-commit

# 3. Configure project
cz init cz-conventional-changelog --save-dev --save-exact
pre-commit install

# 4. Primeiro commit padronizado
git add .
cz commit

# 5. Setup branch protection
gh api repos/:owner/:repo/branches/main/protection -X PUT --field required_status_checks='{"strict":true,"contexts":["ci/tests"]}'
```

---

## 📞 Suporte e Recursos

### **📖 Documentação Adicional:**
- 📋 [Commitizen Setup Guide](./commitizen/README.md)
- 🌿 [GitFlow Workflow](./gitflow/README.md)
- 🛡️ [Pre-commit Configuration](./pre-commit/README.md)
- 🔍 [SonarQube Integration](./sonarqube_codesense/README.md)
- 📖 [API Design Guide](./swagger_stoplight/README.md)
- 🚀 [Trunk-based Development](./trunk-based/README.md)

### **💬 Canais de Suporte:**
- 🎯 **Canal Slack**: `#sdlc-support`
- 📧 **Email**: `devops@embracon.com.br`
- 📅 **Office Hours**: Terças e quintas, 14h-16h
- 📚 **Wiki**: `https://wiki.embracon.com.br/sdlc`

### **🔄 Processo de Melhoria Contínua:**
- 📊 **Retrospectivas mensais** de processo
- 📈 **Review trimestral** de métricas
- 🎯 **Ajustes semestrais** de práticas
- 🚀 **Evolução anual** do framework

---

<p align="center">
  <strong>🚀 Embracon SDLC Framework - Construindo o Futuro com Qualidade 📋</strong><br>
  <em>Padronização • Automação • Excelência • Inovação</em>
</p>

<p align="center">
  <img src="../img/SDLC.png" alt="SDLC Process" width="600"/>
</p>
