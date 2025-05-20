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

- GitFlow: uma versão extrema de gerenciamento de branches de recursos, na qual o desenvolvimento ocorre no branch de desenvolvimento, passa para um branch de lançamento e é mesclado no branch principal.

- Gerenciamento de branches pessoais: semelhante ao gerenciamento de branches de recursos, mas em vez de desenvolver em um branch por recurso, o desenvolvimento é feito por cada desenvolvedor em seu próprio branch. Cada usuário faz merge no branch principal quando conclui seu trabalho.

Muitas equipes decidem seguir um fluxo de trabalho estabelecido, mas outras criam uma abordagem personalizada com base em necessidades específicas. Independentemente da estratégia, é importante comunicar a decisão e a logística do fluxo de trabalho aos membros da equipe e oferecer treinamento se a abordagem for nova para alguns deles.

## Conclusão

A adoção das melhores práticas de controle de versão do Git é crucial para as equipes de desenvolvimento de software, permitindo que elas utilizem recursos e ferramentas incríveis que melhoram os fluxos de trabalho de desenvolvimento e o gerenciamento do histórico de versões. Isso garante a colaboração eficiente entre os membros da equipe, agiliza o processo de revisão e protege a integridade de código do software. A integração de sistemas de controle de versão no ciclo de desenvolvimento tornou-se um requisito fundamental.

Os benefícios do controle de versão são inegáveis, oferecendo um roteiro de sucesso para empresas que desejam prosperar no cenário competitivo do desenvolvimento de software. Ao adotar essas melhores práticas, as equipes podem preparar o terreno para crescimento e inovação futuros.

Fonte: [GitLab - Quais são as melhores práticas de controle de versão do Git?](https://about.gitlab.com/pt-br/topics/version-control/version-control-best-practices/)

# Desenvolvimento baseado em tronco

## Saiba por que essa prática de gerenciamento de controle de versão é comum entre equipes de DevOps.

---

O desenvolvimento baseado em tronco é uma prática de gerenciamento de controle de versão na qual os desenvolvedores unem pequenas atualizações frequentes a um "tronco" central ou branch principal. Agilizando as fases de unificação e integração, ajuda a alcançar a integração contínua (CI/CD) e aumenta a entrega de software e o desempenho organizacional.

Nos primórdios do desenvolvimento de software, os programadores não tinham o luxo dos sistemas modernos de controle de versão. Em vez disso, desenvolviam duas versões do software simultaneamente como forma de rastrear alterações e revertê-las, se necessário. Com o tempo, esse processo se mostrou trabalhoso, caro e ineficiente.

À medida que os sistemas de controle de versão amadureceram, surgiram diversos estilos de desenvolvimento, permitindo que os programadores encontrassem bugs com mais facilidade, codificassem em paralelo com seus colegas e acelerassem a cadência de lançamentos. Hoje, a maioria dos programadores utiliza um de dois modelos de desenvolvimento para entregar software de qualidade: Gitflow e desenvolvimento baseado em trunk.

O Gitflow, que foi popularizado primeiro, é um modelo de desenvolvimento mais rigoroso, no qual apenas determinados indivíduos podem aprovar alterações no código principal. Isso mantém a qualidade do código e minimiza o número de bugs. O desenvolvimento baseado em trunking é um modelo mais aberto, pois todos os desenvolvedores têm acesso ao código principal. Isso permite que as equipes iterem rapidamente e implementem [CI/CD](https://www.atlassian.com/continuous-delivery).

## O que é desenvolvimento baseado em tronco?

---

O desenvolvimento baseado em tronco é uma prática [de gerenciamento de controle de versão](https://www.atlassian.com/git/tutorials/what-is-version-control) na qual os desenvolvedores mesclam pequenas atualizações frequentes em um "tronco" central ou branch principal. É uma prática comum entre equipes [de DevOps](https://www.atlassian.com/devops/what-is-devops) e parte do [ciclo de vida do DevOps](https://www.atlassian.com/devops/what-is-devops/devops-best-practices), pois agiliza as fases de mesclagem e integração. De fato, o desenvolvimento baseado em tronco é uma prática obrigatória de CI/CD. Os desenvolvedores podem criar branches de curta duração com poucos commits pequenos, em comparação com outras estratégias de ramificação de recursos de longa duração. À medida que a complexidade da base de código e o tamanho da equipe aumentam, o desenvolvimento baseado em tronco ajuda a manter o fluxo de lançamentos de produção.

## Gitflow vs. desenvolvimento baseado em tronco

---

[O Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) é um modelo alternativo de ramificação do Git que utiliza ramificações de recursos de longa duração e múltiplas ramificações primárias. O Gitflow possui mais ramificações de longa duração e commits maiores do que o desenvolvimento baseado em trunk. Nesse modelo, os desenvolvedores criam uma ramificação de recurso e adiam a mesclagem com a ramificação principal do trunk até que o recurso esteja concluído. Essas ramificações de recurso de longa duração exigem mais colaboração para serem mescladas, pois apresentam maior risco de se desviarem da ramificação do trunk e introduzir atualizações conflitantes.

O Gitflow também possui ramificações primárias separadas para desenvolvimento, hotfixes, recursos e lançamentos. Existem diferentes estratégias para mesclar commits entre essas ramificações. Como há mais ramificações para gerenciar, geralmente há mais complexidade, o que exige sessões de planejamento e revisão adicionais por parte da equipe.

O desenvolvimento baseado em tronco é muito mais simplificado, pois foca na ramificação principal como fonte de correções e lançamentos. No desenvolvimento baseado em tronco, a ramificação principal é considerada sempre estável, sem problemas e pronta para implantação.

## Benefícios do desenvolvimento baseado em tronco

---

O desenvolvimento baseado em tronco é uma prática obrigatória para [integração contínua](https://www.atlassian.com/continuous-delivery/continuous-integration). Se os processos de construção e teste forem automatizados, mas os desenvolvedores trabalharem em branches de recursos isolados e longos que são integrados infrequentemente a um branch compartilhado, a integração contínua não estará atingindo seu potencial.

### Permite integração contínua de código

No modelo de desenvolvimento baseado em tronco, há um repositório com um fluxo constante de commits fluindo para o branch principal. A adição de uma suíte de [testes automatizados](https://www.atlassian.com/devops/devops-tools/test-automation) e monitoramento de cobertura de código para esse fluxo de commits permite a integração contínua. Quando um novo código é mesclado no tronco, testes automatizados de integração e cobertura de código são executados para validar a qualidade do código.

### Garante revisão contínua de código

Os commits rápidos e pequenos do desenvolvimento baseado em tronco tornam o processo de revisão de código mais eficiente. Com branches pequenos, os desenvolvedores podem ver e revisar rapidamente pequenas alterações. Isso é muito mais fácil em comparação com um branch de recurso de longa duração, onde um revisor lê páginas de código ou inspeciona manualmente uma grande área de alterações de código.

### Possibilita lançamentos consecutivos de código em produção

As equipes devem fazer merges frequentes e diários para o branch principal. O desenvolvimento baseado em tronco busca manter o branch do tronco "verde", ou seja, pronto para implantação a qualquer commit. Testes automatizados, convergência de código e revisões de código fornecem a um projeto de desenvolvimento baseado em tronco a garantia de que está pronto para implantação em produção a qualquer momento. Isso dá à equipe agilidade para implantar frequentemente em produção e estabelecer metas adicionais de lançamentos diários em produção.

### Desenvolvimento baseado em tronco e CI/CD

À medida que o CI/CD cresceu em popularidade, os modelos de branching foram refinados e otimizados, levando ao surgimento do desenvolvimento baseado em tronco. Agora, o desenvolvimento baseado em tronco é um requisito da integração contínua. Com a integração contínua, os desenvolvedores realizam o desenvolvimento baseado em tronco em conjunto com testes automatizados que são executados após cada commit para um tronco. Isso garante que o projeto funcione o tempo todo.

## Melhores práticas de desenvolvimento baseado em tronco

---

O desenvolvimento baseado em tronco garante que as equipes lancem código de forma rápida e consistente. A seguir está uma lista de exercícios e práticas que ajudarão a refinar o ritmo de sua equipe e desenvolver um cronograma de lançamento otimizado.

### Desenvolver em pequenos lotes

O desenvolvimento baseado em tronco segue um ritmo rápido para entregar código em produção. Manter commits e branches pequenos permite um ritmo mais rápido de merges e implantações.

Pequenas alterações de alguns commits ou modificação de algumas linhas de código minimizam a sobrecarga cognitiva. É muito mais fácil para as equipes ter conversas significativas e tomar decisões rápidas ao revisar uma área limitada de código em comparação com um conjunto extenso de alterações.

### Flags de recurso

[Flags de recurso](https://www.atlassian.com/solutions/devops/integrations/feature-flags) complementam muito bem o desenvolvimento baseado em tronco, permitindo que os desenvolvedores envolvam novas alterações em um caminho de código inativo e o ativem posteriormente. Isso permite que os desenvolvedores evitem criar um branch de recurso separado no repositório e, em vez disso, façam commit do novo código de recurso diretamente no branch principal dentro de um caminho de flag de recurso.

### Implementar testes automatizados abrangentes

Testes automatizados são necessários para qualquer projeto de software moderno que pretenda alcançar CI/CD. Existem [múltiplos tipos de testes automatizados](https://www.atlassian.com/continuous-delivery/software-testing/types-of-software-testing) que são executados em diferentes estágios do pipeline de lançamento.

Os testes automatizados ajudam o desenvolvimento baseado em tronco mantendo um ritmo de pequenos lotes à medida que os desenvolvedores mesclam novos commits. A suíte de testes automatizados revisa o código em busca de problemas e aprova ou rejeita automaticamente.

### Realizar revisões de código assíncronas

No desenvolvimento baseado em tronco, a revisão de código deve ser realizada imediatamente e não colocada em um sistema assíncrono para revisão posterior. Os testes automatizados fornecem uma camada de revisão de código preventiva.

### Ter três ou menos branches ativos no repositório de código do aplicativo

Assim que um branch é mesclado, é melhor prática excluí-lo. Um repositório com grande quantidade de branches ativos tem alguns efeitos colaterais indesejáveis.

### Mesclar branches para o tronco pelo menos uma vez por dia

Equipes de alto desempenho que usam desenvolvimento baseado em tronco devem encerrar e mesclar quaisquer branches abertos e prontos para mesclagem pelo menos diariamente.

### Reduzir o número de congelamentos de código e fases de integração

Equipes ágeis de CI/CD não devem precisar de congelamentos de código planejados ou pausas para fases de integração - embora uma organização possa precisar deles por outros motivos.

### Construir rápido e executar imediatamente

Para manter um ritmo rápido de lançamentos, os tempos de execução de construção e teste devem ser otimizados.

## Concluindo...

---

O desenvolvimento baseado em tronco é atualmente o padrão para equipes de engenharia de alto desempenho, pois estabelece e mantém um [cronograma de lançamento de software](https://www.atlassian.com/agile/software-development/release) usando uma estratégia simplificada de branching no Git. Além disso, o desenvolvimento baseado em tronco dá às equipes de engenharia mais flexibilidade e controle sobre como entregam software ao usuário final.

Fonte: [Atlassian - Desenvolvimento baseado em tronco](https://www.atlassian.com/continuous-delivery/continuous-integration/trunk-based-development)

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
