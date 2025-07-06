# Lembrar de quando for criar o akv colocar policies e não RBAC

# Como Usar o Azure Key Vault com External Secrets Operator no Kubernetes

Este guia mostra como integrar o Azure Key Vault (AKV) ao Kubernetes usando o [External Secrets Operator](https://external-secrets.io/), garantindo segurança e automação no gerenciamento de segredos.

---

## 1. Pré-requisitos

- Cluster Kubernetes funcional (ex: Kind, AKS, etc)
- Azure CLI configurado
- Permissão para criar recursos no Azure e no cluster
- External Secrets Operator instalado no cluster

---

## 2. Criar um App Registration no Azure

1. Acesse o [Portal Azure](https://portal.azure.com)
2. Vá em **Azure Active Directory > Registros de aplicativos (App registrations)**
3. Clique em **Novo registro (New registration)**
4. Dê um nome e registre
5. Copie o **Application (client) ID** (será o `ClientId`)
6. Em **Certificados e segredos (Certificates & secrets)**, crie um novo segredo
7. Copie o valor do segredo gerado (será o `ClientSecret`)
8. Anote também o **Directory (tenant) ID** (será o `tenantId`)

---

## 3. Conceder Permissão ao App no Key Vault

### Usando Azure RBAC (recomendado)

1. No portal, vá em **Key Vaults > Seu Key Vault > Access control (IAM)**
2. Clique em **Add > Add role assignment**
3. Escolha a role **Key Vault Secrets User**
4. Em **Assign access to**, selecione **User, group, or service principal**
5. Busque e selecione seu App Registration (pelo nome ou ClientId)
6. Clique em **Save**

**Via Azure CLI:**
```bash
az role assignment create \
  --assignee <CLIENT_ID> \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.KeyVault/vaults/<KEYVAULT_NAME>
```

---

## 4. Criar o Secret no Kubernetes

Crie um arquivo `secret.yaml` com o ClientId e ClientSecret codificados em base64:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: azure-secret-sp
  namespace: default
type: Opaque
data:
  ClientId: <CLIENT_ID_BASE64>
  ClientSecret: <CLIENT_SECRET_BASE64>
```

Para codificar:
```bash
echo -n 'SEU_CLIENT_ID' | base64
echo -n 'SEU_CLIENT_SECRET' | base64
```

Aplique:
```bash
kubectl apply -f secret.yaml
```

---

## 5. Criar o SecretStore

Exemplo de `secretstore-az.yaml`:

```yaml
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: akv-secret-manager-store
  namespace: default
spec:
  provider:
    azurekv:
      tenantId: "<TENANT_ID>"
      vaultUrl: "https://<NOME_DO_KEYVAULT>.vault.azure.net/"
      authSecretRef:
        clientId:
          name: azure-secret-sp
          key: ClientId
        clientSecret:
          name: azure-secret-sp
          key: ClientSecret
```

Aplique:
```bash
kubectl apply -f secretstore-az.yaml
```

---

## 6. Criar o ExternalSecret

Exemplo de `external-secret-akv.yaml`:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: akv-external-secret-manager-store
  namespace: default
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
        key: <NOME_DO_SEGREDO_NO_AKV>
```

Aplique:
```bash
kubectl apply -f external-secret-akv.yaml
```

---

## 7. Verificando

- Veja se o Secret foi criado:
  ```bash
  kubectl get secret my-app-secret-k8s-akv -o yaml
  ```
- Se houver erro 403 (Forbidden), revise as permissões RBAC do App Registration no Key Vault.
- Aguarde alguns minutos após conceder permissões, pois pode haver propagação.

---

## 8. Dicas de Segurança

- Nunca versionar secrets reais em repositórios.
- Prefira sempre usar External Secrets Operator com Key Vault para segredos sensíveis.
- Revogue permissões não utilizadas e siga o princípio do menor privilégio.

---

Pronto! Agora seu cluster Kubernetes busca segredos do Azure Key Vault de forma segura e automatizada.

# Como Permitir Acesso ao Azure Key Vault Usando Access Policies

Se você preferir usar **Access Policies** (políticas de acesso) em vez de Azure RBAC para conceder permissão ao seu aplicativo registrado acessar segredos no Azure Key Vault, siga os passos abaixo:

---

## 1. Obtenha o ClientId do App Registration

- No portal Azure, vá em **Azure Active Directory > Registros de aplicativos (App registrations)**.
- Selecione seu aplicativo.
- Copie o **Application (client) ID** (esse é o ClientId).

---

## 2. Acesse o Azure Key Vault

- No portal Azure, procure por **Key Vaults** e selecione o seu Key Vault.

---

## 3. Adicione uma Access Policy

1. No menu lateral do Key Vault, clique em **Access policies**.
2. Clique em **+ Add Access Policy**.
3. Em **Secret permissions**, selecione pelo menos **Get** (para ler segredos).  
   (Você pode adicionar outras permissões conforme necessário, como `List`, `Set`, etc.)
4. Em **Select principal**, busque e selecione o seu aplicativo registrado (pelo nome ou ClientId).
5. Clique em **Add**.
6. Clique em **Save** para aplicar as mudanças.

---

## 4. Aguarde a Propagação

- Pode levar alguns minutos para as permissões propagarem.

---

## 5. Teste o Acesso

- O External Secrets Operator agora deve conseguir acessar os segredos do Key Vault usando as credenciais do seu App Registration.
- Se receber erro 403, revise as permissões e aguarde mais alguns minutos.

---

## Observações

- Access Policies são o método tradicional de controle de acesso no Key Vault.  
- Para novos Key Vaults, o Azure recomenda o uso de RBAC, mas Access Policies continuam funcionando normalmente.
- Use sempre o princípio do menor privilégio: conceda apenas as permissões necessárias.

---