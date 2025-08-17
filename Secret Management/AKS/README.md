<p align="center">
  <img src="../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# Azure Kubernetes Service (AKS) com Azure Key Vault

## 🏗️ Diagrama da Solução - AKS com Azure Key Vault

```mermaid
graph TB
    %% Azure Cloud Infrastructure
    subgraph "Azure Cloud"
        subgraph "Resource Group: Embracon"
            AKV[Azure Key Vault<br/>akv-test-embracon]
            MI_AKS[Managed Identity<br/>test-aks-akv]
            AKS_CLUSTER[AKS Cluster<br/>aks-test]
        end
        
        subgraph "Azure AD"
            AAD[Azure Active Directory<br/>Tenant]
            GROUP[Azure AD Group<br/>akv-access-group]
            FIC_AKS[Federated Identity<br/>AKS OIDC Trust]
        end
        
        subgraph "AKS Cluster Resources"
            direction TB
            APP[Aplicação]
            ESO[External Secrets Operator]
            SS[SecretStore<br/>Azure Key Vault Config]
            ES[ExternalSecret<br/>Secret Mapping]
            SA[ServiceAccount<br/>workload-identity-sa]
            PODS[Pods com Secrets]
        end
    end

    %% Native Azure Connections
    SA -->|OIDC Token Request| AKS_CLUSTER
    AKS_CLUSTER -->|Issue OIDC Token| SA
    SA -->|OIDC Authentication| AAD
    AAD -->|Validate Federated Creds| FIC_AKS
    FIC_AKS -->|Map to Identity| MI_AKS
    MI_AKS -->|Member of| GROUP
    GROUP -->|RBAC Permissions| AKV
    
    %% Kubernetes Workflow
    APP -->|Request Secret| PODS
    ESO -->|Read Config| SS
    SS -->|Reference| SA
    ES -->|Use SecretStore| SS
    ESO -->|Process ExternalSecret| ES
    ESO -->|Authenticate & Fetch| AKV
    AKV -->|Return Secret Value| ESO
    ESO -->|Create/Update K8s Secret| PODS
    PODS -->|Provide Secret| APP

    %% Styling
    classDef azure fill:#0078d4,stroke:#005a9e,stroke-width:2px,color:#fff
    classDef k8s fill:#326ce5,stroke:#1a5490,stroke-width:2px,color:#fff
    classDef identity fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#fff

    class AKV,MI_AKS,AAD,GROUP,FIC_AKS,AKS_CLUSTER azure
    class APP,ESO,SS,ES,SA,PODS k8s
    class MI_AKS,GROUP,FIC_AKS identity
```

## 🔄 Fluxo de Autenticação Nativo Azure

```mermaid
sequenceDiagram
    participant Pod as Pod AKS
    participant SA as ServiceAccount
    participant AKS as AKS OIDC Provider
    participant AAD as Azure AD
    participant MI as Managed Identity
    participant GROUP as Azure AD Group
    participant AKV as Azure Key Vault
    participant ESO as External Secrets Operator

    Pod->>SA: Solicitar acesso a secret
    SA->>AKS: Solicitar OIDC token
    AKS-->>SA: Retornar OIDC token
    SA->>AAD: Autenticar com OIDC token
    AAD->>MI: Validar Federated Identity
    MI->>GROUP: Verificar membership
    GROUP-->>MI: Confirmar permissões
    MI-->>AAD: Confirmar identidade
    AAD-->>SA: Retornar access token Azure
    ESO->>AKV: Buscar secret (com token Azure)
    AKV-->>ESO: Retornar valor do secret
    ESO->>Pod: Criar K8s secret
    Pod-->>Pod: Consumir secret
```

## 📋 Componentes da Solução AKS

### **Componentes Azure Nativos**
| Componente | Propósito | Configuração |
|-----------|---------|---------------|
| **AKS Cluster** | Cluster Kubernetes gerenciado | Enhanced com OIDC habilitado |
| **Azure Key Vault** | Armazenamento central de secrets | RBAC habilitado |
| **Managed Identity** | Identidade para workloads AKS | `test-aks-akv` |
| **Azure AD Group** | Controle de acesso agrupado | `akv-access-group` |
| **Federated Credentials** | Confiança OIDC com AKS | Trust relationship nativo |

### **Componentes Kubernetes**
| Componente | Propósito | Configuração |
|-----------|---------|---------------|
| **External Secrets Operator** | Sincronização de secrets | Instalado via Helm |
| **ServiceAccount** | Identidade de workload | Anotações Azure configuradas |
| **SecretStore** | Configuração de conexão | Referência ao Key Vault |
| **ExternalSecret** | Mapeamento de secrets | Define quais secrets sincronizar |
| **K8s Secrets** | Secrets nativos do cluster | Criados automaticamente |

## 🔐 Configuração de Segurança Nativa Azure

### **Vantagens da Integração AKS + Azure Key Vault:**
✅ **Integração Nativa**: Solução completamente Azure
✅ **Workload Identity**: Autenticação sem secrets
✅ **RBAC Granular**: Controle via Azure AD Groups
✅ **Zero Secrets**: Tokens OIDC de curta duração
✅ **Auditoria Centralizada**: Logs no Azure Monitor
✅ **Gestão Simplificada**: Ferramentas Azure nativas

### **Modelo de Segurança:**
1. **AKS** gera tokens OIDC para ServiceAccounts
2. **Azure AD** valida tokens via Federated Credentials
3. **Managed Identity** mapeia para Azure AD Group
4. **Azure AD Group** possui permissões RBAC no Key Vault
5. **External Secrets Operator** sincroniza automaticamente

### **Controle de Acesso RBAC:**

#### **Nível Key Vault (Acesso Completo):**
```bash
# Conceder acesso a todos os secrets do cofre
az role assignment create \
  --assignee-object-id $(az ad group show --group "akv-access-group" --query id -o tsv) \
  --assignee-principal-type Group \
  --role "Key Vault Secrets User" \
  --scope $(az keyvault show --name "akv-test-embracon" --resource-group "Embracon" --query id -o tsv)
```

#### **Nível Secret (Acesso Granular):**
```bash
# Conceder acesso apenas a um secret específico
az role assignment create \
  --assignee-object-id $(az ad group show --group "akv-access-group" --query id -o tsv) \
  --assignee-principal-type Group \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.KeyVault/vaults/{vault}/secrets/{secret-name}"
```

## 📚 Guias de Implementação

O **Guia completo para acessar segredos no Azure Key Vault (AKV) a partir do Azure Kubernetes Service (AKS)** está disponível em dois arquivos específicos para diferentes sistemas operacionais:

### **📖 Guias Disponíveis:**

#### **🐧 Para Linux/macOS:**
📁 **Arquivo:** [`README-Linux.md`](./README-Linux.md)
- Comandos específicos para sistemas Unix-like
- Scripts em Bash
- Variáveis de ambiente estilo Unix
- Exemplos com `export` e sintaxe Linux

#### **🪟 Para Windows:**
📁 **Arquivo:** [`README-Windows.md`](./README-Windows.md)
- Comandos específicos para Windows PowerShell
- Scripts em PowerShell
- Variáveis de ambiente estilo Windows (`$Env:`)
- Exemplos com sintaxe PowerShell

### **📋 Conteúdo dos Guias:**

Ambos os guias contêm o **mesmo processo completo**, adaptado para cada sistema operacional:

1. **🏷️ Configuração de Variáveis** - Definição de nomes e identificadores
2. **🏗️ Criação de Recursos Azure** - Resource Group, Managed Identity, Key Vault
3. **☁️ Configuração do AKS** - Cluster com OIDC habilitado
4. **🔄 Federação de Identidade** - Configuração de trust OIDC
5. **📦 External Secrets Operator** - Instalação e configuração
6. **🧑‍💻 ServiceAccount** - Criação com anotações Azure
7. **🏪 SecretStore** - Configuração de conexão com Key Vault
8. **🛂 Permissões RBAC** - Controle de acesso granular
9. **🔁 ExternalSecret** - Sincronização de secrets
10. **✅ Teste e Validação** - Verificação da solução

### **🎯 Escolha do Guia:**

- **Use `README-Linux.md`** se estiver trabalhando em:
  - Linux (Ubuntu, CentOS, etc.)
  - macOS
  - WSL (Windows Subsystem for Linux)
  - Cloud Shell (Bash)

- **Use `README-Windows.md`** se estiver trabalhando em:
  - Windows PowerShell
  - Windows PowerShell Core
  - Azure Cloud Shell (PowerShell)
  - Visual Studio Code com PowerShell

Ambos os guias levam ao **mesmo resultado final**: uma integração segura e funcional entre AKS e Azure Key Vault usando Workload Identity e External Secrets Operator.

## 🔗 Recursos Relacionados

- 📖 [Documentação oficial do Azure Workload Identity](https://azure.github.io/azure-workload-identity/)
- 🔧 [External Secrets Operator Documentation](https://external-secrets.io/)
- 🛡️ [Azure Key Vault RBAC Guide](https://docs.microsoft.com/en-us/azure/key-vault/general/rbac-guide)
- ☁️ [AKS OIDC Issuer Documentation](https://docs.microsoft.com/en-us/azure/aks/use-oidc-issuer)

---

<p align="center">
  <strong>🚀 Secret Management 🛡️</strong><br>
    <em>☁️ Azure Kubernetes Service</em>
</p>