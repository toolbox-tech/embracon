<p align="center">
  <img src="../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

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

---

<p align="center">
  <strong>🚀 Boas Práticas de SDLC 🛡️</strong><br>
    <em>🌿 Trunk-Based Development</em>
</p>