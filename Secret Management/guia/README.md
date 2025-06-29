-----

## Implementando ExternalSecrets com Azure Key Vault (AKV) na Embracon em Clusters Azure (AKS) e Oracle Cloud (OKE)

Este documento detalha o processo de implantação do ExternalSecrets no Kubernetes, integrado ao Azure Key Vault (AKV), para gerenciar segredos de forma segura e eficiente na Embracon. Abordaremos as especificidades de autenticação tanto para clusters **Azure Kubernetes Service (AKS)** quanto para **Oracle Container Engine for Kubernetes (OKE)**.

-----

### O que é ExternalSecrets?

**ExternalSecrets** é um operador do Kubernetes que permite sincronizar segredos de provedores de segredos externos (como Azure Key Vault, AWS Secrets Manager, Google Secret Manager, HashiCorp Vault, etc.) para **Kubernetes Secrets**. Em vez de armazenar seus segredos diretamente no Kubernetes (que, por padrão, não são criptografados em repouso), você os mantém no AKV, e o ExternalSecrets garante que uma cópia sincronizada e atualizada esteja disponível no seu cluster Kubernetes quando necessário.

-----

### Por que usar ExternalSecrets com AKV?

  * **Segurança Centralizada:** Seus segredos críticos permanecem no Azure Key Vault, que é um serviço de gerenciamento de chaves e segredos altamente seguro e auditável.
  * **Princípio do Menor Privilégio:** O Kubernetes não precisa saber os segredos em si, apenas as credenciais para se autenticar no AKV.
  * **Auditoria e Conformidade:** As operações no AKV são logadas, ajudando a Embracon a atender aos requisitos de auditoria e conformidade.
  * **Rotação de Segredos:** Facilita a rotação de segredos no AKV, e o ExternalSecrets pode automaticamente atualizar os Secrets correspondentes no Kubernetes.
  * **Padronização:** Oferece uma maneira consistente de gerenciar segredos em ambientes híbridos ou multi-cloud, mesmo que outros provedores de segredos sejam usados no futuro.

-----

### Pré-requisitos

Antes de iniciar a implantação, certifique-se de que os seguintes pré-requisitos estejam configurados:

1.  **Clusters Kubernetes:**
      * Um cluster **Azure Kubernetes Service (AKS)** em execução.
      * Um cluster **Oracle Container Engine for Kubernetes (OKE)** em execução.
2.  **Azure Key Vault (AKV):**
      * Um Key Vault criado no Azure.
      * Segredos existentes no AKV que você deseja expor ao Kubernetes.
3.  **Credenciais de Acesso ao AKV:**
      * **Para AKS:** Uma Identidade Gerenciada (User-Assigned Managed Identity) no Azure. O método preferido é via **Azure AD Workload Identity**.
      * **Para OKE:** Uma Azure Service Principal (com Client ID e Client Secret).
4.  **Permissões AKV:** A Identidade Gerenciada (para AKS) ou a Service Principal (para OKE) precisa ter permissão de **"Get"** e **"List"** nos segredos do AKV que você deseja acessar.
5.  **`kubectl` e `helm`:** Ferramentas de linha de comando instaladas e configuradas para interagir com ambos os clusters Kubernetes.

-----

### Passo a Passo da Implementação

#### Passo 1: Configurar a Autenticação no Azure Key Vault

A forma como seu cluster Kubernetes se autentica no Azure Key Vault difere entre AKS e OKE.

##### Opção A: Para Clusters AKS (Recomendado: Azure AD Workload Identity)

O Azure AD Workload Identity é a forma mais segura e moderna de autenticar cargas de trabalho AKS com recursos do Azure, sem a necessidade de gerenciar segredos de credenciais.

1.  **Crie uma Identidade Gerenciada (User-Assigned Managed Identity) no Azure:**

    ```bash
    az identity create --resource-group <resource-group-do-aks> --name <nome-da-identidade-gerenciada-aks>
    ```

    Anote o `clientId` e o `principalId` desta identidade.

2.  **Atribua Permissões no Azure Key Vault:**
    Vá para o seu Azure Key Vault no portal do Azure.

      * Clique em **"Access policies"** (Políticas de Acesso).
      * Clique em **"+ Create"**.
      * Em **"Secret permissions"**, selecione **"Get"** e **"List"**.
      * Clique em **"Next"**.
      * Em **"Select principal"**, pesquise pelo `<nome-da-identidade-gerenciada-aks>` que você criou e selecione-o.
      * Clique em **"Next"** e **"Create"**.

3.  **Configure Azure AD Workload Identity no AKS:**

      * **Habilite Workload Identity no seu AKS Cluster (se ainda não estiver):**
        ```bash
        az aks update -g <resource-group-do-aks> -n <nome-do-aks> --enable-oidc-issuer --enable-workload-identity
        ```
      * **Crie uma Credential para a Identidade Gerenciada:**
        ```bash
        az federated-credential create --name "external-secrets-federated-credential" \
            --issuer "$(az aks show -n <nome-do-aks> -g <resource-group-do-aks> --query oidcIssuerProfile.issuerUrl -o tsv)" \
            --subject system:serviceaccount:external-secrets:external-secrets-controller \
            --identity-id "$(az identity show -n <nome-da-identidade-gerenciada-aks> -g <resource-group-do-aks> --query id -o tsv)" \
            --resource-group <resource-group-da-identidade-gerenciada-aks>
        ```
        *Nota:* `external-secrets:external-secrets-controller` é o ServiceAccount padrão do controlador ExternalSecrets. Se você instalar o ExternalSecrets em um namespace diferente ou com um ServiceAccount diferente, ajuste o `subject` de acordo.

##### Opção B: Para Clusters OKE (Azure Service Principal)

Como o OKE não tem integração nativa com Identidades Gerenciadas do Azure, você precisará usar uma Azure Service Principal e armazenar suas credenciais como um Secret no Kubernetes.

1.  **Crie uma Azure Service Principal:**

    ```bash
    az ad sp create-for-rbac --name "http://external-secrets-sp" --role "Contributor" --scopes /subscriptions/<sua-subscription-id>/resourceGroups/<resource-group-do-key-vault>
    ```

      * **IMPORTANTE:** O `--role "Contributor"` aqui é um exemplo. Para produção, atribua apenas as permissões mínimas necessárias (`Secret Get`, `Secret List`) diretamente no Key Vault, não no Resource Group.
      * Anote o `appId` (Client ID) e `password` (Client Secret) da saída.

2.  **Atribua Permissões no Azure Key Vault (para a Service Principal):**
    Vá para o seu Azure Key Vault no portal do Azure.

      * Clique em **"Access policies"** (Políticas de Acesso).
      * Clique em **"+ Create"**.
      * Em **"Secret permissions"**, selecione **"Get"** e **"List"**.
      * Clique em **"Next"**.
      * Em **"Select principal"**, pesquise pelo `<appId-da-service-principal>` que você criou e selecione-o.
      * Clique em **"Next"** e **"Create"**.

3.  **Crie um Secret Kubernetes com as Credenciais da Service Principal (no OKE):**
    Crie um arquivo YAML (ex: `azure-sp-secret.yaml`):

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: azure-service-principal-secret
      namespace: external-secrets # Ou o namespace onde o ExternalSecrets está instalado
    type: Opaque
    stringData:
      clientid: "<seu-appId-da-service-principal>"
      clientsecret: "<seu-password-da-service-principal>"
    ```

    Aplique este Secret no seu cluster OKE:

    ```bash
    kubectl apply -f azure-sp-secret.yaml
    ```

#### Passo 2: Instalar o ExternalSecrets no Kubernetes (AKS e OKE)

Este passo é o mesmo para ambos os tipos de cluster.

1.  **Adicione o repositório Helm do ExternalSecrets:**

    ```bash
    helm repo add external-secrets https://charts.external-secrets.io
    helm repo update
    ```

2.  **Instale o ExternalSecrets:**

    ```bash
    helm install external-secrets external-secrets/external-secrets \
      --namespace external-secrets --create-namespace \
      --set installCRDs=true # Garante que os CRDs sejam instalados
    ```

    Verifique se os pods estão em execução:

    ```bash
    kubectl get pods -n external-secrets
    ```

    Você deverá ver pods como `external-secrets-controller` e `external-secrets-webhook` em estado `Running`.

#### Passo 3: Criar um `SecretStore` ou `ClusterSecretStore` para o Azure Key Vault

A configuração do `SecretStore` ou `ClusterSecretStore` dependerá do método de autenticação e do escopo desejado (namespace ou cluster).

##### Opção A: Para AKS (usando Azure AD Workload Identity com `ClusterSecretStore`)

Crie um arquivo YAML, por exemplo, `akv-clustersecretstore-aks.yaml`:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: azure-key-vault-store # Nome do seu ClusterSecretStore
spec:
  provider:
    azurekv:
      vaultUrl: "https://<seu-nome-do-key-vault>.vault.azure.net/" # Substitua pelo URL do seu AKV
      auth:
        # Para Azure AD Workload Identity, o controlador ExternalSecrets
        # usará a identidade do ServiceAccount federado.
        # Nenhuma configuração adicional é necessária aqui no ClusterSecretStore
        # se o ServiceAccount do controlador ExternalSecrets já estiver configurado
        # com a federação de credenciais (Passo 1.A.3).
        managedIdentity:
          # Omitir clientId se a federação já estiver configurada para o ServiceAccount padrão.
          # Se você tiver várias identidades federadas ou quiser especificar:
          # clientId: "<seu-client-id-da-identidade-gerenciada-aks>"
```

Aplique o `ClusterSecretStore` no seu cluster AKS:

```bash
kubectl apply -f akv-clustersecretstore-aks.yaml
```

##### Opção B: Para OKE (usando Azure Service Principal com `ClusterSecretStore`)

Crie um arquivo YAML, por exemplo, `akv-clustersecretstore-oke.yaml`:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: azure-key-vault-store # Nome do seu ClusterSecretStore
spec:
  provider:
    azurekv:
      vaultUrl: "https://<seu-nome-do-key-vault>.vault.azure.net/" # Substitua pelo URL do seu AKV
      auth:
        secretRef:
          clientId:
            name: azure-service-principal-secret # Nome do Secret Kubernetes criado no Passo 1.B.3
            key: clientid # Chave dentro do Secret que contém o Client ID
          clientSecret:
            name: azure-service-principal-secret # Nome do Secret Kubernetes
            key: clientsecret # Chave dentro do Secret que contém o Client Secret
          tenantId: "<seu-tenant-id-do-azure>" # Substitua pelo seu Azure Tenant ID
```

Para encontrar seu Tenant ID do Azure, você pode usar: `az account show --query tenantId -o tsv`.

Aplique o `ClusterSecretStore` no seu cluster OKE:

```bash
kubectl apply -f akv-clustersecretstore-oke.yaml
```

**Verifique se o `SecretStore` (ou `ClusterSecretStore`) foi criado com sucesso em ambos os clusters:**

```bash
kubectl get clustersecretstore # Ou kubectl get secretstore -n <namespace>
```

#### Passo 4: Criar um `ExternalSecret` ou `ClusterExternalSecret` para Sincronizar Segredos

Este passo é o mesmo para ambos os tipos de cluster, pois o `ExternalSecret` apenas referencia o `SecretStore` ou `ClusterSecretStore` que já foi configurado para a autenticação específica do cluster.

##### Opção A: Usando `ExternalSecret` (Namespace-Scoped)

Este é o uso mais comum e recomendado para a maioria dos segredos de aplicação, pois ele cria um Secret no mesmo namespace em que o `ExternalSecret` está definido.

Crie um arquivo YAML, por exemplo, `my-app-external-secret.yaml`:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-application-secret
  namespace: default # O namespace onde o Secret Kubernetes será criado
spec:
  refreshInterval: 1m # Opcional: frequência para verificar atualizações do segredo no AKV
  secretStoreRef:
    name: azure-key-vault-store # Referência ao ClusterSecretStore (ou SecretStore se você usar um local)
    kind: ClusterSecretStore # Use SecretStore se for um SecretStore local
  target:
    name: my-app-k8s-secret # Nome do Secret Kubernetes que será criado
    creationPolicy: Owner # Garante que o Secret seja excluído com o ExternalSecret
  data:
  - secretKey: db_password # Nome da chave no Secret Kubernetes
    remoteRef:
      key: NomeDoSegredoNoAKV # O nome exato do segredo no seu Azure Key Vault
      # property: "" # Opcional: se o segredo no AKV for um JSON e você quiser uma propriedade específica
      # version: "" # Opcional: Especifique a versão do segredo no AKV
  - secretKey: api_key # Outra chave, se houver
    remoteRef:
      key: OutroSegredoNoAKV
```

Substitua `NomeDoSegredoNoAKV` e `OutroSegredoNoAKV` pelos nomes reais dos seus segredos no Azure Key Vault.

Aplique o `ExternalSecret` no cluster desejado (AKS ou OKE):

```bash
kubectl apply -f my-app-external-secret.yaml
```

##### Opção B: Usando `ClusterExternalSecret` (Cluster-Scoped)

Use esta opção apenas para segredos que são verdadeiramente globais e precisam ser injetados em múltiplos namespaces.

Crie um arquivo YAML, por exemplo, `my-global-cluster-external-secret.yaml`:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterExternalSecret
metadata:
  name: global-certificate-secret # Nome do seu ClusterExternalSecret
spec:
  refreshInterval: 5m # Frequência para verificar atualizações
  secretStoreRef:
    name: azure-key-vault-store # Referência ao ClusterSecretStore
    kind: ClusterSecretStore
  target:
    name: global-tls-certificate # Nome do Secret Kubernetes a ser criado em cada namespace
    creationPolicy: Owner
  data:
  - secretKey: tls.crt
    remoteRef:
      key: GlobalTLSCertificate # Nome do segredo no AKV para o certificado
  - secretKey: tls.key
    remoteRef:
      key: GlobalTLSKey # Nome do segredo no AKV para a chave
  namespaceSelector: # Define em quais namespaces o Secret será criado
    matchLabels:
      env: production # Exemplo: injetar em todos os namespaces com label 'env: production'
    # ou use matchExpressions:
    # matchExpressions:
    # - key: kubernetes.io/metadata.name
    #   operator: In
    #   values: ["namespace-a", "namespace-b"]
  # namespaceTemplates: # Opcional: para injetar em namespaces que ainda não existem
  # - labels:
  #     env: staging
  #   template:
  #     data:
  #       tls.crt: "{{ .tls.crt }}"
  #       tls.key: "{{ .tls.key }}"
```

Aplique o `ClusterExternalSecret` no cluster desejado (AKS ou OKE):

```bash
kubectl apply -f my-global-cluster-external-secret.yaml
```

**Importante:** Para que o `ClusterExternalSecret` funcione, os namespaces de destino devem existir e ter os labels correspondentes (se `namespaceSelector` for usado).

#### Passo 5: Verificar o `Secret` no Kubernetes

Após alguns momentos, o ExternalSecrets deve ter sincronizado o segredo do AKV para um `Secret` no Kubernetes.

  * **Para `ExternalSecret`:**
    ```bash
    kubectl get secret my-app-k8s-secret -n default -o yaml
    ```
  * **Para `ClusterExternalSecret`:**
    Verifique em um dos namespaces selecionados (ex: `kubectl get secret global-tls-certificate -n production -o yaml`).

Você deverá ver o conteúdo do segredo decodificado (o valor estará em base64, mas o `kubectl` normalmente o decodifica na saída).

#### Passo 6: Usar o `Secret` no seu `Deployment`

Agora que o segredo está disponível como um `Secret` padrão do Kubernetes, você pode usá-lo em seus `Deployments` da Embracon como variáveis de ambiente ou montando-o como um arquivo.

##### Exemplo de uso como variável de ambiente:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
  namespace: default # Ou o namespace onde o Secret foi criado
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app-container
        image: sua-imagem-de-aplicacao:latest # Substitua pela imagem do seu aplicativo
        env:
        - name: DATABASE_PASSWORD # Variável de ambiente no container
          valueFrom:
            secretKeyRef:
              name: my-app-k8s-secret # Nome do Secret Kubernetes gerado pelo ExternalSecrets (ou ClusterExternalSecret)
              key: db_password # Chave dentro do Secret
        - name: GLOBAL_CERT_CRT # Exemplo de uso de segredo de ClusterExternalSecret
          valueFrom:
            secretKeyRef:
              name: global-tls-certificate # Nome do Secret gerado pelo ClusterExternalSecret
              key: tls.crt
```

##### Exemplo de uso montando como arquivo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment-file
  namespace: default # Ou o namespace onde o Secret foi criado
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app-file
  template:
    metadata:
      labels:
        app: my-app-file
    spec:
      containers:
      - name: my-app-container-file
        image: sua-imagem-de-aplicacao:latest # Substitua pela imagem do seu aplicativo
        volumeMounts:
        - name: app-secret-volume
          mountPath: "/mnt/app-secrets" # Onde os arquivos do segredo da aplicação serão montados
          readOnly: true
        - name: global-cert-volume
          mountPath: "/mnt/global-certs" # Onde os arquivos do segredo global serão montados
          readOnly: true
      volumes:
      - name: app-secret-volume
        secret:
          secretName: my-app-k8s-secret # Nome do Secret Kubernetes (do ExternalSecret)
          items:
          - key: db_password
            path: db_password.txt # O segredo será acessível em /mnt/app-secrets/db_password.txt
      - name: global-cert-volume
        secret:
          secretName: global-tls-certificate # Nome do Secret Kubernetes (do ClusterExternalSecret)
          items:
          - key: tls.crt
            path: certificate.crt
          - key: tls.key
            path: private.key
```

-----

### Considerações Importantes para a Embracon

  * **Autenticação Específica por Cloud:** Lembre-se que a autenticação do ExternalSecrets com o AKV é diferente para AKS (Identidade Gerenciada/Workload Identity) e OKE (Service Principal). Configure o **`SecretStore`** ou **`ClusterSecretStore`** apropriadamente para cada ambiente.
  * **Identidade Gerenciada (Best Practice para AKS):** Para clusters AKS, sempre priorize o uso de Identidades Gerenciadas, especialmente via Azure AD Workload Identity. É a forma mais segura e não exige gerenciamento de credenciais dentro do Kubernetes.
  * **Service Principal (para OKE):** Ao usar Service Principal, trate o Secret Kubernetes que armazena o Client ID e Client Secret com o máximo de segurança. Considere ferramentas como Sealed Secrets ou Vault para gerenciar este Secret.
  * **Permissões no AKV:** Siga o princípio do menor privilégio. Conceda apenas as permissões "Get" e "List" (se necessário) aos segredos específicos que o ExternalSecrets precisa acessar.
  * **Escopo de Segredos (`SecretStore` vs. `ClusterSecretStore` e `ExternalSecret` vs. `ClusterExternalSecret`):**
      * Para a maioria dos casos, especialmente em ambientes multi-tenant ou com várias equipes, use **`SecretStore`** (namespace-scoped) e **`ExternalSecret`** (namespace-scoped). Isso garante que as permissões de acesso ao AKV sejam restritas ao namespace que realmente precisa dos segredos, aumentando o isolamento e a segurança.
      * Use **`ClusterSecretStore`** apenas se múltiplos namespaces precisarem acessar o *mesmo* Key Vault e você quiser centralizar a configuração de acesso ao AKV.
      * Use **`ClusterExternalSecret`** com cautela, e apenas para segredos que são verdadeiramente globais (ex: certificados TLS curinga, chaves de API globais) e precisam ser injetados em muitos namespaces. O risco de um segredo comprometido que está presente em todo o cluster é maior.
  * **Ciclo de Vida do Segredo:** Entenda que o ExternalSecrets sincroniza e, por padrão, é o "dono" do Secret Kubernetes. Se o `ExternalSecret` (ou `ClusterExternalSecret`) for excluído, o `Secret` correspondente no Kubernetes também será.
  * **Auditoria:** Configure logs no Azure Key Vault para auditar quem acessou os segredos e quando.
  * **Monitoramento:** Monitore os logs do pod do ExternalSecrets para quaisquer erros de sincronização ou problemas de permissão.

Ao seguir este guia e as melhores práticas de segurança, a Embracon poderá gerenciar seus segredos de forma eficaz e segura usando ExternalSecrets e Azure Key Vault, independentemente de seus clusters estarem no Azure ou na Oracle Cloud.