# Guia para acessar um segredo no Azure Key Vault (AKV) a partir do Azure Kubernetes Service (AKS)

Inicialmente, devemos nos atentar ao [**Secret Zero**](./anexos/secret-zero.md) para não expormos um segredo importante. 

A Azure disponibiliza a seguintes formas de acessar o AKV do AKS, conforme este [link](https://learn.microsoft.com/pt-br/azure/aks/csi-secrets-store-identity-access?tabs=azure-portal&pivots=access-with-service-connector), mas o driver CSI (Container Storage Interface) do Azure Key Vault para o AKS (Azure Kubernetes Service) possui algumas limitações ao acessar chaves e segredos. Uma delas é que o driver não atualiza automaticamente um volume montado usando um ConfigMap ou Secret quando o segredo é alterado. Para que as alterações sejam refletidas, o aplicativo precisa recarregar o arquivo ou reiniciar o pod. Além disso, o driver cria uma identidade gerenciada no grupo de recursos do nó, e essa identidade é automaticamente atribuída aos conjuntos de escalabilidade de máquinas virtuais (VMSS). Você pode usar essa identidade ou uma identidade gerenciada pelo usuário para acessar o Key Vault. Segue o [link](https://learn.microsoft.com/pt-br/azure/aks/csi-secrets-store-driver) para consulta.

Como solução iremos usar o [External Secrets](https://external-secrets.io/) usando a Federação de Identidade de Carga de Trabalho do Azure AD para acessar serviços gerenciados do Azure, como o Key Vault, sem precisar gerenciar segredos . Você precisa configurar uma relação de confiança entre o seu Cluster Kubernetes e o Azure AD.

Será usado OIDC (OpenID Connect) para integrar o Kubernetes com o Azure AD porque ele permite a Federação de Identidade de Carga de Trabalho. Com OIDC, seu cluster Kubernetes pode autenticar aplicações diretamente no Azure AD sem precisar armazenar secrets sensíveis (como client secret) dentro do cluster.

Vantagens de usar OIDC:

- **Elimina o "Secret Zero"**: Não é necessário armazenar um segredo fixo para acessar o Key Vault.
- **Mais seguro**: O acesso é realizado por meio de tokens temporários, reduzindo o risco de vazamento de credenciais.
- **Automatizado**: Permite que workloads (pods) obtenham permissões dinâmicas conforme a configuração do Azure AD.
- **Menos gerenciamento manual**: Não é preciso renovar ou rotacionar secrets manualmente.

## Criar um Azure AD Application (aad)

Para permitir que o AKS acesse o Azure Key Vault usando OIDC, é necessário criar um aplicativo no Azure Active Directory (Azure AD). Siga os passos abaixo:

1. **Crie um aplicativo no Azure AD:**

  No portal do Azure, acesse **Azure Active Directory** > **Registros de aplicativos** > **Novo registro**.

  - Nome: `akv-test` (ou outro nome de sua escolha)
  - Tipos de conta: Deixe como padrão (Contas neste diretório organizacional)
  - Redirecionamento: Não é necessário para este cenário

2. **Anote o Application (client) ID** e o **Directory (tenant) ID**. Eles serão usados na configuração do acesso.

3. **Permissões:**  
  Não é necessário adicionar permissões de API neste momento, pois o acesso será controlado via RBAC e identidade federada.

4. **Configurar identidade federada:**  
  Após criar o aplicativo, configure a identidade federada conforme os comandos e instruções da seção "AKS com OIDC" deste guia.

Com o aplicativo criado, prossiga para associá-lo à ServiceAccount do Kubernetes usando o comando `azwi` mostrado anteriormente.

## Acesso individualizado aos secrets

Usaremos o RBAC para conceder acesso individualizado aos secrets no Azure Key Vault (AKV) via Azure AD (AAD).

1. **Crie um grupo no Azure AD** para reunir todos os usuários que devem ter acesso ao secret.
  - No portal do Azure, acesse **Azure Active Directory** > **Grupos** > **Novo grupo**.
  - Defina um nome e adicione os membros desejados.

2. **Ao criar o AKV, escolha RBAC como política de acesso**.
  - No momento da criação do Key Vault, selecione "Controle de acesso baseado em função do Azure (RBAC)" como método de autorização.

3. **Atribua a função adequada ao grupo no AKV**:
  - Após criar o secret, acesse o Key Vault e vá em **Controle de Acesso (IAM)**.
  - Clique em **Adicionar** > **Adicionar atribuição de função**.
  - Selecione a função **Usuário de Segredos do Cofre de Chaves**.
  - Em "Atribuir acesso a", escolha **Usuário, grupo ou entidade de serviço**.
  - Clique em **Selecionar membros** e escolha o grupo criado anteriormente.
  - Clique em **Examinar + atribuir** para finalizar.

4. **Os usuários pertencentes ao grupo terão acesso ao secret** conforme as permissões da função atribuída.

Dessa forma, o acesso aos secrets é controlado centralmente pelo Azure AD, facilitando o gerenciamento e a auditoria.

## AKS com OIDC e External Secrets

A Azur fornece um tutorial para [Criar um provedor do OpenID Connect no Serviço de Kubernetes do Azure (AKS)](https://learn.microsoft.com/pt-br/azure/aks/use-oidc-issuer). O Workload Identity Federation (WIF) utiliza o OIDC (OpenID Connect) como mecanismo de autenticação. O OIDC é um protocolo de identidade baseado em OAuth 2.0, que permite que o AKS emita tokens de identidade para workloads (pods) sem a necessidade de armazenar secrets sensíveis no cluster. Com o WIF, o Azure AD confia nos tokens OIDC emitidos pelo cluster Kubernetes, permitindo que workloads autenticadas acessem recursos do Azure (como o Key Vault) de forma segura e automatizada, eliminando o "Secret Zero" e facilitando o gerenciamento de identidades.

[External Secrets AKV](https://external-secrets.io/v0.6.1/provider/azure-key-vault/)

[Azure AD Workload Identity](https://azure.github.io/azure-workload-identity/docs/quick-start.html#5-create-a-kubernetes-service-account)

Será utilizados o [azwi](https://azure.github.io/azure-workload-identity/docs/introduction.html)

Comandos para executar a associação entre a ServiceAccount do Kubernetes e o aplicativo do Azure AD, utilize o comando abaixo:

```bash
azwi serviceaccount create phase sa \
  --aad-application-name "akv-test" \
  --service-account-namespace "default" \
  --service-account-name "workload-identity-sa"
```

O que faz?

Cria uma ServiceAccount no Kubernetes chamada workload-identity-sa no namespace default.
Associa essa ServiceAccount a uma aplicação registrada no Azure AD chamada "akv-test".
Essa associação permite que pods que usam essa ServiceAccount obtenham tokens OIDC e acessem recursos do Azure (como o Key Vault) usando a identidade federada, sem precisar de secrets fixos.
Onde ver se deu certo?
No Kubernetes:

Verifique se a ServiceAccount foi criada:

```bash
kubectl get serviceaccount workload-identity-sa -n default
```

No Azure:

Verifique se a identidade federada foi criada na aplicação do Azure AD:

1. No portal do Azure, acesse "Azure Active Directory" > "Registros de aplicativos" > selecione "akv-test".
2. Em "Identidades federadas", confira se há uma entrada referente ao seu cluster AKS e ServiceAccount.

```bash
azwi serviceaccount create phase federated-identity \
--aad-application-name "akv-test" \
--service-account-namespace "default" \
--service-account-name "workload-identity-sa" \
--service-account-issuer-url "https://brazilsouth.oic.prod-aks.azure.com/38270d4e-aea5-4430-b2c7-1deb696ac290/1b6b5131-fecf-4aee-8f74-53829b7d4c67/" 
```
Verificar se deu certo: 

```bash
kubectl describe serviceaccount workload-identity-sa -n default
az ad app federated-credential list --id 5516b68c-297b-4132-ac9d-dd55ef1cba77 
```

Acessar [identidade empresarial](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Users/objectId/42569e6b-97c7-4bd8-a383-4fb79f858f11/appId/5516b68c-297b-4132-ac9d-dd55ef1cba77/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/)

# Explicação dos Conceitos no README: Acesso ao Azure Key Vault (AKV) via AKS

Este README descreve uma abordagem segura para acessar segredos armazenados no Azure Key Vault (AKV) a partir de um cluster Azure Kubernetes Service (AKS). Vamos decompor os principais conceitos:

## 1. Secret Zero
- **Problema**: O "segredo zero" é a credencial inicial necessária para obter outros segredos, criando um ponto único de falha.
- **Solução proposta**: Eliminar a necessidade de armazenar qualquer segredo fixo no cluster usando Federação de Identidade.

## 2. Métodos de Acesso AKV → AKS
### Driver CSI do Azure Key Vault
- **Funcionamento**: Monta segredos do AKV como volumes nos pods.
- **Limitações**:
  - Não atualiza automaticamente quando segredos mudam (requer reinício do pod)
  - Cria identidade gerenciada no grupo de recursos do nó

### External Secrets Operator
- **Vantagem**: Solução mais flexível que sincroniza segredos do AKV para Secrets nativos do Kubernetes
- **Integração**: Usa Workload Identity Federation com OIDC para acesso seguro

## 3. OpenID Connect (OIDC) e Federação de Identidade
- **O que é**: Protocolo de autenticação baseado em OAuth 2.0
- **Benefícios**:
  - Elimina necessidade de armazenar secrets no cluster
  - Usa tokens JWT temporários e de curta duração
  - Permite autenticação direta no Azure AD

## 4. Workload Identity Federation
- **Como funciona**: Estabelece confiança entre o AKS e Azure AD
- **Fluxo**:
  1. Cluster AKS emite tokens OIDC
  2. Azure AD valida esses tokens
  3. Pods podem assumir identidade do Azure AD sem secrets

## 5. Componentes Principais
### Azure AD Application
- Atua como identidade central para acesso ao AKV
- Configurado com credenciais federadas para aceitar tokens do AKS

### Kubernetes ServiceAccount
- Vinculada ao aplicativo do Azure AD via anotações
- Pods usam esta ServiceAccount para obter tokens de acesso

### RBAC no Azure
- Controle granular de acesso aos segredos no AKV
- Grupos do Azure AD definem quem tem acesso

## 6. Ferramentas Utilizadas
- **azwi**: CLI para configurar Workload Identity
- **External Secrets Operator**: Operador Kubernetes que sincroniza segredos externos

## Fluxo Completo
1. Pod inicia com ServiceAccount configurada
2. OIDC emite token JWT para o pod
3. Pod usa token para autenticar no Azure AD
4. Azure AD valida token contra aplicativo registrado
5. Pod recebe token de acesso para AKV
6. External Secrets sincroniza segredos para o cluster

Esta abordagem oferece segurança superior ao eliminar a necessidade de armazenar credenciais fixas, enquanto mantém a praticidade de acesso aos segredos necessários para as aplicações.