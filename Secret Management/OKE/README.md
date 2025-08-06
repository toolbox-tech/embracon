# OIDC no Oracle Cloud (OKE)

No Oracle Kubernetes Engine (OKE), o processo de configuração do OIDC é diferente do AKS, pois o OKE não expõe um endpoint OIDC por padrão para autenticação de workloads. 

Para a utilização do OIDC é necessário que o cluster seja do tipo `ENHANCED_CLUSTER` e deve-se ativar o `Open Id Connect Discovery`.

## Requisitos principais antes de habilitar o OIDC no OKE

- Disponível apenas em clusters com Kubernetes versão 1.21 ou superior.
- Compatível exclusivamente com clusters nativos de VCN, ou seja, clusters cujos endpoints da API Kubernetes estão em uma sub-rede do seu próprio VCN. Consulte a [documentação de migração para clusters nativos de VCN](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengmovingvcnnative.htm).
- Suportado em nós gerenciados, nós virtuais e nós autogerenciados.
- Permitido somente em clusters do tipo *enhanced* (não disponível para clusters do tipo *basic*).

## Como fazer login usando o OCI CLI

Para autenticar-se e usar o OCI CLI, siga os passos abaixo:

1. **Instale o OCI CLI**  
    Siga as instruções oficiais:  
    https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

2. **Configure o CLI**  
    Execute o comando abaixo e siga o assistente interativo:
    ```sh
    oci setup config
    ```
    Você precisará informar:
    - OCID do usuário
    - OCID do tenancy
    - Região
    - Caminho para a chave privada

3. **Faça login**  
    O OCI CLI utiliza as credenciais configuradas no arquivo `~/.oci/config`. Após configurar, você já estará autenticado para executar comandos.

4. **Teste a autenticação**  
    Por exemplo, para listar os compartimentos:
    ```sh
    oci iam compartment list --all
    ```
    ![oci iam compartment list --all](./gif/oci_list.gif)

> **Nota:** O login via OIDC é utilizado para workloads no cluster OKE, enquanto o OCI CLI usa autenticação baseada em chave.

## Como criar um cluster OKE via CLI

Para criar um cluster OKE do tipo `ENHANCED_CLUSTER` com todos os recursos de rede necessários, siga os passos abaixo usando o OCI CLI:

### 1. Defina as variáveis necessárias

```bash
COMPARTMENT_OCID=$(oci iam compartment list --query "data[?name=='<COMPARTMENT_NAME>'].id | [0]" --raw-output)
K8S_VERSION="v1.33.1"
IMAGE_OCID="ocid1.image.oc1.sa-vinhedo-1.aaaaaaaasbj464azhcqhh4u37pqbpdmyga5iaitbkuh3umsmwqkteh7yxt4q"

```

### 2. Crie os recursos no OKE

```bash
### 1. Crie uma VCN (Virtual Cloud Network)
VCN_OCID=$(oci network vcn create \
  --compartment-id $COMPARTMENT_OCID \
  --cidr-block 10.0.0.0/16 \
  --display-name "OKE-VCN" \
  --query 'data.id' --raw-output)
echo "VCN_OCID=$VCN_OCID"

> **Nota:**  
> O comando acima cria a VCN e armazena o OCID na variável `VCN_OCID` para uso nos próximos comandos.

#### Caso Precise pegar o OCID novamente
VCN_OCID=oci network vcn list --compartment-id $COMPARTMENT_OCID --query "data[?\"display-name\"=='OKE-VCN'].id | [0]" --raw-output


### 2. Crie sub-redes públicas e privadas

# Sub-rede pública (para Load Balancer, por exemplo)
OKE_Public_Subnet_OCID=$(oci network subnet create \
  --compartment-id $COMPARTMENT_OCID \
  --vcn-id $VCN_OCID \
  --cidr-block 10.0.1.0/24 \
  --display-name "OKE-Public-Subnet" \
  --prohibit-public-ip-on-vnic false \
  --query 'data.id' --raw-output)
echo "OKE_Public_Subnet_OCID=$OKE_Public_Subnet_OCID"

# Pegar o OCID
OKE_Public_Subnet_OCID=$(oci network subnet list --compartment-id $COMPARTMENT_OCID --query "data[?\"display-name\"=='OKE-Public-Subnet'].id | [0]" --raw-output)

# Sub-rede privada (para nós de trabalho)
OKE_Private_Subnet_OCID=$(oci network subnet create \
  --compartment-id $COMPARTMENT_OCID \
  --vcn-id $VCN_OCID \
  --cidr-block 10.0.2.0/24 \
  --display-name "OKE-Private-Subnet" \
  --prohibit-public-ip-on-vnic true \
  --query 'data.id' --raw-output)
echo "OKE_Private_Subnet_OCID=$OKE_Private_Subnet_OCID"

### 3. Crie o Internet Gateway (IG)
IG=$(oci network internet-gateway create \
  --compartment-id $COMPARTMENT_OCID \
  --vcn-id $VCN_OCID \
  --display-name "OKE-IG" \
  --is-enabled true \
  --query 'data.id' --raw-output)
echo "IG=$IG"

### 4. Crie o NAT Gateway
NAT_G=$(oci network nat-gateway create \
  --compartment-id $COMPARTMENT_OCID \
  --vcn-id $VCN_OCID \
  --display-name "OKE-NAT" \
  --query 'data.id' --raw-output)
echo "NAT_G=$NAT_G"

### 5. Crie o Service Gateway (SGW)
SERVICE_ID=$(oci network service list --all --query "data[?name=='All VCP Services In Oracle Services Network'].id | [0]" --raw-output)
SGW=$(oci network service-gateway create \
  --compartment-id $COMPARTMENT_OCID \
  --vcn-id $VCN_OCID \
  --services "[{\"serviceId\":\"$SERVICE_ID\"}]" \
  --display-name "OKE-SGW" \
  --query 'data.id' --raw-output)
echo "SGW=$SGW"

### 6. Atualize as tabelas de rotas das sub-redes conforme necessário

# Crie a tabela de rotas para a sub-rede pública apontando para o Internet Gateway
ROUTE_TABLE_PUBLIC_OCID=$(oci network route-table create \
  --compartment-id $COMPARTMENT_OCID \
  --vcn-id $VCN_OCID \
  --display-name "OKE-Public-Route-Table" \
  --route-rules '[{"cidrBlock":"0.0.0.0/0","networkEntityId":"'$IG'"}]' \
  --query 'data.id' --raw-output)
echo "ROUTE_TABLE_PUBLIC_OCID=$ROUTE_TABLE_PUBLIC_OCID"

# Atualize a sub-rede pública para usar a nova tabela de rotas
oci network subnet update \
  --subnet-id $OKE_Public_Subnet_OCID \
  --route-table-id $ROUTE_TABLE_PUBLIC_OCID

# Crie a tabela de rotas para a sub-rede privada apontando para o NAT Gateway e Service Gateway
Não foi
ROUTE_TABLE_PRIVATE_OCID=$(oci network route-table create \
  --compartment-id $COMPARTMENT_OCID \
  --vcn-id $VCN_OCID \
  --display-name "OKE-Private-Route-Table" \
  --route-rules '[{"cidrBlock":"0.0.0.0/0","networkEntityId":"'$NAT_G'"},{"destination":"svc:all-vcn-services-in-oracle-services-network","destinationType":"SERVICE_CIDR_BLOCK","networkEntityId":"'$SGW'"}]' \
  --query 'data.id' --raw-output)
echo "ROUTE_TABLE_PRIVATE_OCID=$ROUTE_TABLE_PRIVATE_OCID"

# Atualize a sub-rede privada para usar a nova tabela de rotas
oci network subnet update \
  --subnet-id $OKE_Private_Subnet_OCID \
  --route-table-id $ROUTE_TABLE_PRIVATE_OCID

### 7. Crie o cluster OKE do tipo ENHANCED

oci ce cluster create \
    --compartment-id $COMPARTMENT_OCID \
    --name "OKE-Enhanced-Cluster" \
    --vcn-id $VCN_OCID \
    --type ENHANCED_CLUSTER \
    --kubernetes-version $K8S_VERSION \
    --endpoint-public-ip-enabled true \
    --endpoint-subnet-id $OKE_Public_Subnet_OCID \
    --cluster-pod-network-options '[{"cniType":"OCI_VCN_IP_NATIVE"}]' \
    --open-id-connect-discovery-enabled true \
    --query 'data.id' --raw-output
CLUSTER_OCID=$(oci ce cluster list --compartment-id $COMPARTMENT_OCID --query "data[?name=='OKE-Enhanced-Cluster'].id | [0]" --raw-output)
echo "CLUSTER_OCID=$CLUSTER_OCID"

### 8. Crie o pool de nós (Node Pool)
# Para ver a lista de imagens e seu OCID
oci ce node-pool-options get --node-pool-option-id all

# Pegar domínio disponível
AD_NAME=$(oci iam availability-domain list --compartment-id $COMPARTMENT_OCID --query "data[0].name" --raw-output)
echo $AD_NAME

oci ce node-pool create \
  --compartment-id $COMPARTMENT_OCID \
  --cluster-id $CLUSTER_OCID \
  --name "OKE_NodePool" \
  --kubernetes-version $K8S_VERSION \
  --node-shape VM.Standard.E3.Flex \
  --node-shape-config '{"ocpus":1,"memoryInGBs":16}' \
  --node-image-id $IMAGE_OCID \
  --placement-configs '[{"availabilityDomain":"'"$AD_NAME"'","subnetId":"'"$OKE_Public_Subnet_OCID"'"}]' \
  --size 1

```

> **Dica:** Consulte a documentação oficial para mais detalhes:
> https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/create-cluster.htm

## Como criar um cluster OKE via Console

### Abra o menu de navegação e selecione **Developer Services**. Em **Containers & Artifacts**, clique em **Kubernetes Clusters (OKE)**.

![Create Cluster Menu](./img/menu.png)

### Clique em `Create Cluster`

![Create Cluster 0](./img/0.png)

### Escolha em `Quick create`

![Create Cluster 1](./img/1.png)

> Nota
>
> O Quick create irá criar automaticamente:
> - Virtual Cloud Network (VCN)
> - Internet Gateway (IG)
> - NAT Gateway (NAT)
> - Service Gateway (SGW)
> - Kubernetes cluster
> - Kubernetes worker node(s) e node pool  
> Esses recursos são provisionados para facilitar a criação rápida do cluster OKE.

### Coloque o nome e escolha as definições necessárias

![Create Cluster 2](./img/2.png)

![Create Cluster 3](./img/3.png)

![Create Cluster 4](./img/4.png)

### Clique em `Next`

![Create Cluster 5](./img/5.png)

### Verifique e clique em `Create cluster`

![Create Cluster 6](./img/6.png)

![Create Cluster 7](./img/7.png)

### Aguarde o provisionamento e clique em `Close`

![Create Cluster 8](./img/8.png)

### Aguarde o `Cluster status` virar `Active`

![Create Cluster 9](./img/9.png)

![Create Cluster 10](./img/10.png)

> Nota
>
> Observer que o OIDC Discovery está como `Not enabled`

### Anote o OCID do cluster.

## Atualizando um cluster para o tipo `ENHANCED_CLUSTER`

### Via Cli

```bash
oci ce cluster update --cluster-id <cluster-ocid> --type ENHANCED_CLUSTER
```

![Upgarde Cluster](./gif/oci_upgrade.gif)

### Via Console

1. Abra o menu de navegação e selecione **Developer Services**. Em **Containers & Artifacts**, clique em **Kubernetes Clusters (OKE)**.
2. Selecione o compartimento que contém o cluster desejado.
3. Na página de clusters, clique no nome do cluster do tipo *Basic* que você deseja atualizar para *Enhanced*.
4. Na página de detalhes do cluster, verifique que o tipo está como **Cluster type: Basic**.
5. Clique em **Upgrade to Enhanced Cluster**.
6. Confirme a opção **Upgrade to Enhanced Cluster** para prosseguir com a atualização.  
  > **Atenção:** Após a atualização, não é possível reverter o cluster para o tipo *Basic*.
7. Clique em **Upgrade** para iniciar o processo.
8. Após a conclusão, a página de detalhes do cluster exibirá **Cluster type: Enhanced**.

![Upgrade 1](./img/upgrade_cluster_1.png)

![Upgrade 2](./img/upgrade_cluster_2.png)

![Upgrade 3](./img/upgrade_cluster_3.png)

![Upgrade 4](./img/upgrade_cluster_4.png)

## Como ativar o Open Id Connect Discovery via Console

### Clique em editar

![OIDC 1](./img/1_oidc.png)

![OIDC 2](./img/2_oidc.png)

![OIDC 3](./img/3_oidc.png)

## Como ativar o Open Id Connect Discovery via CLI

1. Crie o arquivo [cluster-enable-oidc.json](cluster-enable-oidc.json) e coloque o seguinte conteúdo:

```json
{
  "options": {
    "openIdConnectDiscovery": {
      "isOpenIdConnectDiscoveryEnabled": true
    }
  }
}
```

2. Para atualizar o cluster, execute o seguinte comando :
```bash
oci ce cluster update --cluster-id <CLUSTER_OCID> --from-json file://cluster-enable-oidc.json
```
![Enable OIDC](./gif/oci_issuer.gif)

>Nota
>
> Substitua o <CLUSTER_OCID> pelo OCDI do Cluster
> Caso apareça `WARNING: Updates to options and freeform-tags and defined-tags and image-policy-config will replace any existing values. Are you sure you want to continue? [y/N]:` digite y

3. Pegue o `open-id-connect-discovery-endpoint` com o comando:
```bash
oci ce cluster get --cluster-id <CLUSTER_OCID> | grep -B1 'open-id-connect-discovery'
```

![Get OIDC](./gif/oci_oidc.gif)
>Nota
>
> Substitua o <CLUSTER_OCID> pelo OCDI do Cluster

## Acessar o AKV a partir de um OKE

### 1. Crie uma Federated Credential em uma Managed Identity na Azure

```sh
az identity federated-credential create \
  --name "oke-federated-credential" \
  --identity-name "<NOME_DA_MANAGED_IDENTITY>" \
  --resource-group "<RESOURCE_GROUP>" \
  --issuer "<open-id-connect-discovery-endpoint>" \
  --subject "system:serviceaccount:<NAMESPACE>:<SERVICE_ACCOUNT_NAME>"
```

### 2. Conecte-se ao cluster criado

```bash
oci ce cluster create-kubeconfig --cluster-id "$CLUSTER_OCID" --file $HOME/.kube/config --region "$REGION" --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
```

### 3. Instale o External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
```

### 4. Crie a ServiceAccount no Kubernetes

Crie um arquivo `service-account.yaml` com as anotações necessárias (client-id, tenant-id).
(Substitua pelos valores das variáveis que você obteve anteriormente):

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workload-identity-sa
  annotations:
    azure.workload.identity/client-id: "<CLIENT_ID>"
    azure.workload.identity/tenant-id: "<TENANT_ID>"
```

> **Nota:**  
> - Substitua `<CLIENT_ID>` pelo valor da variável `$CLIENT_ID`.
> - Substitua `<TENANT_ID>` pelo valor da variável `$TENANT_ID`.

```bash
kubectl apply -f service-account.yaml
```

### 5. Crie o Secret Store

Crie um arquivo `secret-store.yaml` com o seguinte conteúdo, substituindo os valores conforme necessário:

```yaml
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: akv-secret-manager-store
  namespace: <namespace>
spec:
  provider:
    azurekv:
      authType: WorkloadIdentity
      vaultUrl: "<KEY_VAULT_URL>"
      serviceAccountRef:
        name: workload-identity-sa
```

> **Nota:**  
> - Substitua `<namespace>` pelo namespace desejado no cluster Kubernetes (por exemplo, `default` se estiver usando o namespace padrão).
> - Substitua `<KEY_VAULT_URL>` pelo valor da variável `$KEY_VAULT_URL`.

Aplique o recurso:

```bash
kubectl apply -f secret-store.yaml
```

### 6. Conceda Permissões no Key Vault

No portal do Azure ou via CLI, atribua a função **Usuário de Segredos do Cofre de Chaves** ao grupo `$SEU_GROUP_NAME` no Key Vault para ter acesso a todos os Segredos do Cofre.

Caso queira dar acesso somente a um segredo específico, vá até o segredo, clique no mesmo, acesse Controle de acesso IAM e adicione a função **Usuário de Segredos do Cofre de Chaves** ao grupo `$SEU_GROUP_NAME`.

![1](../anexos/img/1.png)

![2](../anexos/img/2.png)

![3](../anexos/img/3.png)

![4](../anexos/img/4.png)

### 7. Crie o External Secret

Crie um arquivo `external-secret.yaml` com o seguinte conteúdo, substituindo os valores conforme necessário:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: akv-external-secret-manager-store
  namespace: <namespace>
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: akv-secret-manager-store
    kind: SecretStore
  target:
    name: my-app-secret-k8s-akv
    creationPolicy: Owner
  data:
    - secretKey: my-akv-secret-key
      remoteRef:
        key: <nome-do-segredo-no-akv>
```

> **Nota:**  
> - Substitua `<namespace>` pelo namespace desejado no cluster Kubernetes (por exemplo, `default` se estiver usando o namespace padrão).
> - Substitua `nome-do-segredo-no-akv` pelo nome do segredo existente no Key Vault que deseja sincronizar.
> - O campo `secretKey` define o nome da chave no Secret do Kubernetes.

Aplique o recurso:

```bash
kubectl apply -f external-secret.yaml
```
