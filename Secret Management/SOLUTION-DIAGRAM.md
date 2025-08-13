# Diagrama da Solução - Secret Management

## 🏗️ Arquitetura da Solução de Gerenciamento de Segredos

```mermaid
graph TB
    %% GitHub Actions
    subgraph "GitHub Actions"
        GHA[GitHub Actions Workflow<br/>akv.yml]
        OIDC[OIDC Authentication<br/>Managed Identity]
    end

    %% Azure Infrastructure
    subgraph "Azure Cloud"
        subgraph "Resource Group: Embracon"
            AKV[Azure Key Vault<br/>meukeyvault123]
            MI[Managed Identity<br/>github-actions-terraform]
        end
        
        subgraph "Azure AD"
            AAD[Azure Active Directory<br/>Tenant]
            FIC[Federated Identity<br/>Credentials]
        end
    end

    %% Terraform
    subgraph "Infrastructure as Code"
        subgraph "Terraform Module"
            MOD_MAIN[module/main.tf<br/>Key Vault Resource]
            MOD_VAR[module/variables.tf<br/>Input Variables]
            MOD_OUT[module/outputs.tf<br/>Outputs]
        end
        
        subgraph "Terraform Resource"
            RES_MAIN[resource/main.tf<br/>Module Call]
            RES_PROV[resource/provider.tf<br/>Azure Provider]
            RES_VAR[resource/variables.tf<br/>Variables]
        end
    end

    %% Kubernetes Integration
    subgraph "Kubernetes Clusters"
        subgraph "AKS - Azure"
            ESO_AKS[External Secrets Operator]
            SS_AKS[SecretStore<br/>Azure Key Vault]
            ES_AKS[ExternalSecret<br/>Resource]
            SA_AKS[ServiceAccount<br/>Workload Identity]
            POD_AKS[Application Pods]
        end
        
        subgraph "OKE - Oracle"
            ESO_OKE[External Secrets Operator]
            SS_OKE[SecretStore<br/>Azure Key Vault]
            ES_OKE[ExternalSecret<br/>Resource]
            POD_OKE[Application Pods]
        end
    end

    %% Connections - GitHub to Azure
    GHA -->|OIDC Auth| OIDC
    OIDC -->|Authenticate| AAD
    AAD -->|Federated Creds| FIC
    FIC -->|Identity| MI
    
    %% Connections - Terraform
    GHA -->|Execute| RES_MAIN
    RES_MAIN -->|Uses| MOD_MAIN
    MOD_MAIN -->|Creates| AKV
    MI -->|Permissions| AKV
    
    %% Connections - AKS
    SA_AKS -->|Workload Identity| AAD
    ESO_AKS -->|Reads Config| SS_AKS
    SS_AKS -->|References| SA_AKS
    ES_AKS -->|Uses| SS_AKS
    ES_AKS -->|Fetches Secrets| AKV
    ESO_AKS -->|Creates K8s Secrets| POD_AKS
    
    %% Connections - OKE
    ESO_OKE -->|Reads Config| SS_OKE
    ES_OKE -->|Uses| SS_OKE
    ES_OKE -->|Fetches Secrets| AKV
    ESO_OKE -->|Creates K8s Secrets| POD_OKE

    %% Styling
    classDef azure fill:#0078d4,stroke:#005a9e,stroke-width:2px,color:#fff
    classDef github fill:#24292e,stroke:#1b1f23,stroke-width:2px,color:#fff
    classDef terraform fill:#623ce4,stroke:#4b2db8,stroke-width:2px,color:#fff
    classDef k8s fill:#326ce5,stroke:#1a5490,stroke-width:2px,color:#fff
    classDef secret fill:#ff6b35,stroke:#cc5429,stroke-width:2px,color:#fff

    class AKV,MI,AAD,FIC azure
    class GHA,OIDC github
    class MOD_MAIN,MOD_VAR,MOD_OUT,RES_MAIN,RES_PROV,RES_VAR terraform
    class ESO_AKS,SS_AKS,ES_AKS,SA_AKS,POD_AKS,ESO_OKE,SS_OKE,ES_OKE,POD_OKE k8s
```

## 🔄 Fluxo de Implementação

### 1. **Provisionamento da Infraestrutura** (GitHub Actions + Terraform)
```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub Actions
    participant Azure as Azure Cloud
    participant TF as Terraform

    Dev->>GH: Trigger workflow (manual/push)
    GH->>Azure: OIDC Authentication
    Azure-->>GH: Access Token
    GH->>TF: Execute Terraform
    TF->>Azure: Create Key Vault
    Azure-->>TF: Key Vault Created
    TF-->>GH: Deployment Complete
    GH-->>Dev: Success Notification
```

### 2. **Integração com Kubernetes** (External Secrets Operator)
```mermaid
sequenceDiagram
    participant App as Application
    participant K8s as Kubernetes
    participant ESO as External Secrets Operator
    participant AKV as Azure Key Vault

    App->>K8s: Request Secret
    K8s->>ESO: ExternalSecret Resource
    ESO->>AKV: Fetch Secret (via SecretStore)
    AKV-->>ESO: Secret Value
    ESO->>K8s: Create/Update K8s Secret
    K8s-->>App: Provide Secret
```

## 📋 Componentes da Solução

### **Azure Components**
| Component | Purpose | Configuration |
|-----------|---------|---------------|
| **Azure Key Vault** | Central secret store | `meukeyvault123.vault.azure.net` |
| **Managed Identity** | OIDC authentication | `github-actions-terraform` |
| **Federated Credentials** | GitHub trust relationship | Repository-specific subjects |
| **RBAC Roles** | Permission management | Contributor + User Access Admin |

### **Terraform Components**
| Component | Location | Purpose |
|-----------|----------|---------|
| **Module** | `infra-secrets/module/` | Reusable Key Vault module |
| **Resource** | `infra-secrets/resource/` | Module instantiation |
| **Provider** | `provider.tf` | Azure provider configuration |
| **Variables** | `variables.tf` | Input parameters |

### **Kubernetes Integration**
| Component | Purpose | Supports |
|-----------|---------|----------|
| **External Secrets Operator** | Secret synchronization | AKS, OKE, Generic K8s |
| **SecretStore** | Key Vault connection config | Workload Identity (AKS), Service Principal (OKE) |
| **ExternalSecret** | Secret mapping definition | Multiple secret types |
| **ServiceAccount** | Authentication mechanism | Azure Workload Identity |

### **GitHub Actions**
| Component | Purpose | Configuration |
|-----------|---------|---------------|
| **Workflow** | Automated deployment | `.github/workflows/akv.yml` |
| **OIDC** | Secure authentication | No long-lived secrets |
| **Secrets** | Authentication credentials | Client ID, Tenant ID |
| **Variables** | Configuration values | Subscription ID |

## 🔐 Security Architecture

### **Authentication Flow**
1. **GitHub Actions** → OIDC Token → **Azure AD**
2. **Federated Credentials** → **Managed Identity**
3. **RBAC Permissions** → **Azure Key Vault**

### **Kubernetes Access Patterns**

#### **AKS (Azure Kubernetes Service)**
- **Workload Identity**: Native Azure integration
- **Pod Identity**: Direct AAD authentication
- **No secrets required**: Automatic token injection

#### **OKE (Oracle Kubernetes Engine)**
- **Service Principal**: Traditional authentication
- **Client Secret**: Stored as K8s secret
- **Cross-cloud access**: Azure resources from Oracle

## 🎯 Benefits of This Architecture

### **Security**
✅ **Zero long-lived secrets** in GitHub
✅ **Centralized secret management** in Azure Key Vault
✅ **Fine-grained RBAC** permissions
✅ **Audit trails** across all components

### **Scalability**
✅ **Multi-cloud support** (Azure AKS + Oracle OKE)
✅ **Reusable Terraform modules**
✅ **Automated deployment** pipeline
✅ **Secret rotation** capabilities

### **Operational Excellence**
✅ **Infrastructure as Code** with Terraform
✅ **GitOps workflow** with GitHub Actions
✅ **Standardized secret access** across environments
✅ **Comprehensive monitoring** and logging

## 🔄 Deployment Flow

1. **Developer** pushes code to repository
2. **GitHub Actions** triggers on workflow_dispatch
3. **OIDC authentication** establishes trust with Azure
4. **Terraform** provisions/updates Key Vault infrastructure
5. **External Secrets Operator** synchronizes secrets to Kubernetes
6. **Applications** consume secrets via standard K8s mechanisms

This architecture provides a robust, secure, and scalable solution for managing secrets across multi-cloud Kubernetes environments with centralized storage in Azure Key Vault.
