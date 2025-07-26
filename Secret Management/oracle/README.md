# OIDC no Oracle Cloud (OKE)

No Oracle Kubernetes Engine (OKE), o processo de configuração do OIDC é diferente do AKS, pois o OKE já expõe um endpoint OIDC por padrão para autenticação de workloads. Esse endpoint pode ser utilizado para federação de identidade com provedores externos, como Azure ou OCI Vault.

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

> **Nota:** O login via OIDC é utilizado para workloads no cluster OKE, enquanto o OCI CLI usa autenticação baseada em chave.

## Como criar um cluster Oracle Kubernetes Engine (OKE) 

```bash
# Defina as variáveis
COMPARTMENT_ID="<OCID_DO_COMPARTIMENTO>"
VCN_ID="<OCID_DA_VCN>"
SUBNET_ID="<OCID_DA_SUBNET>"
CLUSTER_NAME="meu-cluster-oke"

# Crie o cluster OKE
oci ce cluster create \
  --name "$CLUSTER_NAME" \
  --compartment-id "$COMPARTMENT_ID" \
  --vcn-id "$VCN_ID" \
  --kubernetes-version "v1.29.1" \
  --endpoint-config '{"isPublicIpEnabled": true}' \
  --options '{"serviceLbSubnetIds":["'"$SUBNET_ID"'"]}'

# Aguarde o cluster ser criado e pegue o OCID do cluster
# Agora crie o node pool com shape econômico
NODE_POOL_NAME="meu-nodepool"
CLUSTER_ID="<OCID_DO_CLUSTER_CRIADO>"

oci ce node-pool create \
  --compartment-id "$COMPARTMENT_ID" \
  --cluster-id "$CLUSTER_ID" \
  --name "$NODE_POOL_NAME" \
  --kubernetes-version "v1.29.1" \
  --node-shape "VM.Standard.E2.1.Micro" \
  --node-metadata '{"ssh_authorized_keys":"'"$(cat ~/.ssh/id_rsa.pub)"'"}' \
  --subnet-ids '["'"$SUBNET_ID"'"]' \
  --quantity-per-subnet 1
```

## Como obter o issuer OIDC do OKE

1. **Acesse o Console OCI**
2. Vá em **Developer Services > Kubernetes Clusters (OKE)** e selecione seu cluster.
3. No painel do cluster, procure pela seção **Cluster Details** ou **Access**.
4. O endpoint OIDC geralmente segue o padrão:

    ```
    https://containerengine.<region>.oci.oraclecloud.com/oke/<cluster-ocid>/oidc
    ```

    **Exemplo:**
    ```
    https://containerengine.sa-saopaulo-1.oci.oraclecloud.com/oke/ocid1.cluster.oc1.sa-saopaulo-1.aaaaaaaaxxxxxxxx/oidc
    ```

5. Copie esse URL para utilizar como issuer ao criar a credencial federada no Azure ou outro provedor.

## Comandos úteis

- Para obter as credenciais do cluster:
  ```sh
  oci ce cluster create-kubeconfig --cluster-id <CLUSTER_OCID> --file $HOME/.kube/config --region <REGION>
  ```

## Exemplo de uso do issuer OIDC do OKE no Azure

```sh
az identity federated-credential create \
  --name "oke-federated-credential" \
  --identity-name "<NOME_DA_MANAGED_IDENTITY>" \
  --resource-group "<RESOURCE_GROUP>" \
  --issuer "<OKE_OIDC_ISSUER_URL>" \
  --subject "system:serviceaccount:<NAMESPACE>:<SERVICE_ACCOUNT_NAME>"
```

---

## Resumo

- No OKE, o OIDC já está disponível por padrão.
- Basta obter o issuer URL pelo painel do cluster e usá-lo normalmente para federação de identidade.
- Não é necessário habilitar o OIDC manualmente.
