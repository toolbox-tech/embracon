# OIDC no Oracle Cloud (OKE)

No Oracle Kubernetes Engine (OKE), o processo de configuração do OIDC é diferente do AKS, pois o OKE não expõe um endpoint OIDC por padrão para autenticação de workloads. 

Para a utilização do OIDC é necessário que o cluster seja do tipo `ENHANCED_CLUSTER` e deve-se ativar o `Open Id Connect Discovery`.

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
    ![oci iam compartment list --all](./gif/render1753546934412.gif)

> **Nota:** O login via OIDC é utilizado para workloads no cluster OKE, enquanto o OCI CLI usa autenticação baseada em chave.

## Como criar um cluster OKE via CLI

Para criar um cluster OKE do tipo `ENHANCED_CLUSTER` com todos os recursos de rede necessários, siga os passos abaixo usando o OCI CLI:


### 1. Defina as variáveis necessárias

```bash
COMPARTMENT_OCID="<OCID do compartimento>"
VCN_OCID="<OCID da VCN>"
OKE_PUBLIC_SUBNET_OCID="<OCID da sub-rede pública>"
OKE_PRIVATE_SUBNET_OCID="<OCID da sub-rede privada>"
CLUSTER_OCID="<OCID do cluster OKE>"
K8S_VERSION="<versão do Kubernetes, ex: v1.27.2>"
IMAGE_OCID="<OCID da imagem para os nós>"
```

### 2. Crie os recursos no OKE

```bash
### 1. Crie uma VCN (Virtual Cloud Network)
oci network vcn create \
  --compartment-id <COMPARTMENT_OCID> \
  --cidr-block 10.0.0.0/16 \
  --display-name "OKE-VCN"


### 2. Crie sub-redes públicas e privadas

# Sub-rede pública (para Load Balancer, por exemplo)
oci network subnet create \
  --compartment-id <COMPARTMENT_OCID> \
  --vcn-id <VCN_OCID> \
  --cidr-block 10.0.1.0/24 \
  --display-name "OKE-Public-Subnet" \
  --prohibit-public-ip-on-vnic false

# Sub-rede privada (para nós de trabalho)
oci network subnet create \
  --compartment-id <COMPARTMENT_OCID> \
  --vcn-id <VCN_OCID> \
  --cidr-block 10.0.2.0/24 \
  --display-name "OKE-Private-Subnet" \
  --prohibit-public-ip-on-vnic true

### 3. Crie o Internet Gateway (IG)

oci network internet-gateway create \
  --compartment-id <COMPARTMENT_OCID> \
  --vcn-id <VCN_OCID> \
  --display-name "OKE-IG" \
  --is-enabled true

### 4. Crie o NAT Gateway

oci network nat-gateway create \
  --compartment-id <COMPARTMENT_OCID> \
  --vcn-id <VCN_OCID> \
  --display-name "OKE-NAT"

### 5. Crie o Service Gateway (SGW)

oci network service-gateway create \
  --compartment-id <COMPARTMENT_OCID> \
  --vcn-id <VCN_OCID> \
  --services '[{"service-id":"all"}]' \
  --display-name "OKE-SGW"

### 6. Atualize as tabelas de rotas das sub-redes conforme necessário

- Sub-rede pública: rotas para o Internet Gateway
- Sub-rede privada: rotas para o NAT Gateway e Service Gateway

### 7. Crie o cluster OKE do tipo ENHANCED

oci ce cluster create \
  --compartment-id <COMPARTMENT_OCID> \
  --name "OKE-Enhanced-Cluster" \
  --vcn-id <VCN_OCID> \
  --kubernetes-version <K8S_VERSION> \
  --cluster-type ENHANCED_CLUSTER \
  --endpoint-config '{"isPublicIpEnabled": true, "subnetId": "<OKE-Public-Subnet_OCID>"}'

### 8. Crie o pool de nós (Node Pool)

oci ce node-pool create \
  --compartment-id <COMPARTMENT_OCID> \
  --cluster-id <CLUSTER_OCID> \
  --name "OKE-NodePool" \
  --kubernetes-version <K8S_VERSION> \
  --node-shape "VM.Standard.E4.Flex" \
  --node-shape-config '{"ocpus":1,"memoryInGBs":16}' \
  --subnet-ids '["<OKE-Private-Subnet_OCID>"]' \
  --node-source-details '{"imageId":"<IMAGE_OCID>","sourceType":"IMAGE"}' \
  --quantity-per-subnet 1
```

> **Dica:** Consulte a documentação oficial para mais detalhes:
> https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/create-cluster.htm

## Como criar um cluster OKE via Console

### Passo 1:

Selecione o compartimento e a versão mais recente do Kubernetes. Neste exemplo, selecionamos o Endpoint da API como Público e os Nós de Trabalho como Privados.

![1](./img/1.webp)

Criação do Cluster OKE - Passo 1

### Passo 2:

Escolha o shape de computação com a quantidade de OCPUs/Memória necessária e a imagem de sistema operacional mais recente suportada. Para este demo, defina a contagem de nós como 1.

![2](./img/2.webp)

Criação do Cluster OKE - Passo 2

#### Passo 3:

Revise as configurações e prossiga com a criação do cluster do tipo "enhanced".

![1](./img/3.webp)

Aguarde a conclusão da criação do cluster OKE e anote o OCID do cluster.

## Atualizando um cluster para o tipo `ENHANCED_CLUSTER`

### Via Cli

```bash
oci ce cluster update --cluster-id <cluster-ocid> --type ENHANCED_CLUSTER
```

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

## Como ativar o Open Id Connect Discovery

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
>Nota
>
> Substitua o <CLUSTER_OCID> pelo OCDI do Cluster
> Caso apareça `WARNING: Updates to options and freeform-tags and defined-tags and image-policy-config will replace any existing values. Are you sure you want to continue? [y/N]:` digite y

3. Pegue o `open-id-connect-discovery-endpoint` com o comando:
```bash
oci ce cluster get --cluster-id <CLUSTER_OCID> | grep -B1 'open-id-connect-discovery'

```
>Nota
>
> Substitua o <CLUSTER_OCID> pelo OCDI do Cluster

## Exemplo de uso do issuer OIDC do OKE no Azure

```sh
az identity federated-credential create \
  --name "oke-federated-credential" \
  --identity-name "<NOME_DA_MANAGED_IDENTITY>" \
  --resource-group "<RESOURCE_GROUP>" \
  --issuer "<open-id-connect-discovery-endpoint>" \
  --subject "system:serviceaccount:<NAMESPACE>:<SERVICE_ACCOUNT_NAME>"
```

---

## Resumo

- No OKE, o OIDC já está disponível por padrão.
- Basta obter o issuer URL pelo painel do cluster e usá-lo normalmente para federação de identidade.
- Não é necessário habilitar o OIDC manualmente.
