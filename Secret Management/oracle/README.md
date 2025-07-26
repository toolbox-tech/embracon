## OIDC no Oracle Cloud (OKE)

No Oracle Kubernetes Engine (OKE), o processo de configuração do OIDC é diferente do AKS, pois o OKE já expõe um endpoint OIDC por padrão para autenticação de workloads. Esse endpoint pode ser utilizado para federação de identidade com provedores externos, como Azure ou OCI Vault.

### Como obter o issuer OIDC do OKE

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

### Comandos úteis

- Para obter as credenciais do cluster:
  ```sh
  oci ce cluster create-kubeconfig --cluster-id <CLUSTER_OCID> --file $HOME/.kube/config --region <REGION>
  ```

### Exemplo de uso do issuer OIDC do OKE no Azure

```sh
az identity federated-credential create \
  --name "oke-federated-credential" \
  --identity-name "<NOME_DA_MANAGED_IDENTITY>" \
  --resource-group "<RESOURCE_GROUP>" \
  --issuer "<OKE_OIDC_ISSUER_URL>" \
  --subject "system:serviceaccount:<NAMESPACE>:<SERVICE_ACCOUNT_NAME>"
```

---

### Resumo

- No OKE, o OIDC já está disponível por padrão.
- Basta obter o issuer URL pelo painel do cluster e usá-lo normalmente para federação de identidade.
- Não é necessário habilitar o OIDC manualmente.
