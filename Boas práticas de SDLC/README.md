# Boas Práticas para SDLC (Software Development Life Cycle)

## 1. Padrão de Commits com Commitizen
### Ferramenta
- Uso do [Commitizen](https://commitizen-tools.github.io/commitizen/) para padronizar mensagens de commit via CLI interativa.
- Exemplo de configuração (`.cz.yaml`):
    ```yaml
    commitizen:
        name: cz_conventional_commits
        version: 1.0.0
        tag_format: "v$version"
    ```

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

## 2. Padrão de Política de Pull Request (PR)
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
    - Validar mensagens de commit (com `commitlint`).

---

## 3. Padrão de Branches e Commits
### Estratégia de Branching
- **GitFlow** (para releases planejadas) ou **Trunk-Based** (para CI/CD).
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

## 4. Treinamento em SCM (GitFlow vs. Trunk-Based)
### GitFlow
- **Branches**: `main`, `develop`, `feature/*`, `release/*`, `hotfix/*`.
- **Uso**: Projetos com versões estáveis (ex: enterprise).

### Trunk-Based
- **Branches**: `main` (sempre deployável) + feature flags.
- **Uso**: Times ágeis com deploys diários.

### Workshop
- Práticas de `rebase`, `cherry-pick` e resolução de conflitos.

---

## 5. Linter e Code Quality
### Ferramentas
- **SonarQube**: Análise estática e cobertura de testes.
- **Linters**:
    - ESLint/Prettier (JavaScript).
    - Pylint (Python).
- **Validação**:
    - Bloquear merge se:
        - Cobertura de testes < 80%.
        - Critical issues no Sonar.

---

## 6. API Design (Swagger/Stoplight)
### Documentação
- **Swagger/OpenAPI**: Especificação contratual.
- **Stoplight**: Design colaborativo.
- **Padrões**:
    - Versionamento (`/v1/users`).
    - Exemplos de payloads.

---

## 7. Documentação e Treinamento
### Arquitetura
- **Diagramas**: C4 Model ou UML (usando Draw.io).
- **ADRs**: Registro de decisões técnicas.

### Onboarding
- Wiki com:
    - Guia de setup.
    - Fluxo de deploy.

---

## 8. Políticas de Segurança no GitHub
### Mínimo Recomendado
- **Branch Protection**:
    - Bloquear `force push` em `main`.
    - Exigir 2FA para todos os devs.
- **Dependências**:
    - Scan com Dependabot.

---

## 9. Ferramentas Recomendadas
| Categoria       | Ferramentas               |
|----------------|--------------------------|
| Commits        | Commitizen, commitlint   |
| Code Quality   | SonarQube, ESLint        |
| API Design     | Swagger, Stoplight       |
| Automação      | GitHub Actions, husky    |

---

## Fluxo Completo SDLC
![Fluxo Completo do SDLC](img/SDLC.png)
