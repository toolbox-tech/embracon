# Guia para acessar um segredo no Azure Key Vault (AKV) a partir do Azure Kubernetes Service (AKS)

Inicialmente, devemos nos atentar ao [**Secret Zero**](./anexos/secret-zero.md) para não expormos um segredo importante. 

A Azure disponibiliza a seguintes formas de acessar o AKV do AKS, conforme este [link](https://learn.microsoft.com/pt-br/azure/aks/csi-secrets-store-identity-access?tabs=azure-portal&pivots=access-with-service-connector), mas o driver CSI (Container Storage Interface) do Azure Key Vault para o AKS (Azure Kubernetes Service) possui algumas limitações ao acessar chaves e segredos. Uma delas é que o driver não atualiza automaticamente um volume montado usando um ConfigMap ou Secret quando o segredo é alterado. Para que as alterações sejam refletidas, o aplicativo precisa recarregar o arquivo ou reiniciar o pod. Além disso, o driver cria uma identidade gerenciada no grupo de recursos do nó, e essa identidade é automaticamente atribuída aos conjuntos de escalabilidade de máquinas virtuais (VMSS). Você pode usar essa identidade ou uma identidade gerenciada pelo usuário para acessar o Key Vault. 

Como solução iremos usar o [External Secrets](https://external-secrets.io/) usando a Federação de Identidade de Carga de Trabalho do Azure AD para acessar serviços gerenciados do Azure, como o Key Vault, sem precisar gerenciar segredos . Você precisa configurar uma relação de confiança entre o seu Cluster Kubernetes e o Azure AD.

Será usado OIDC (OpenID Connect) para integrar o Kubernetes com o Azure AD porque ele permite a Federação de Identidade de Carga de Trabalho. Com OIDC, seu cluster Kubernetes pode autenticar aplicações diretamente no Azure AD sem precisar armazenar secrets sensíveis (como client secret) dentro do cluster.

Vantagens de usar OIDC:

- **Elimina o "Secret Zero"**: Não é necessário armazenar um segredo fixo para acessar o Key Vault.
- **Mais seguro**: O acesso é realizado por meio de tokens temporários, reduzindo o risco de vazamento de credenciais.
- **Automatizado**: Permite que workloads (pods) obtenham permissões dinâmicas conforme a configuração do Azure AD.
- **Menos gerenciamento manual**: Não é preciso renovar ou rotacionar secrets manualmente.

## Acesso individualizado aos secrets

Usaremos o RBAC para conceder acesso individualizado aos secrets.

1. Devemos criar um grupo para agrupar todos os usuários que devam ter acesso ao secret.

2. Ao criar o AKV, devemos escolher o RBAC como política de acesso.

3. Após criar o secret, clique no mesmo e vá em Controle de Acesso (IAM), clique em Adicionar + -> Adicionar atribuição de função -> selecione Usuário de Segredos do Cofre de Chaves -> Atribuir acesso a Usuário, grupo ou entidade de serviço -> + Selecionar membros -> selecione o grupo criado anteriormente -> Examinar + atribuir.

4. Os usuários que pertecem ao grupo escolhido terão acesso a este segredo.

## AKS
