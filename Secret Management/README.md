# 🗝️ Guia para acessar um segredo no Azure Key Vault (AKV) usando OIDC

Este guia apresenta um passo a passo para acessar segredos do Azure Key Vault (AKV) de forma segura usando OIDC (OpenID Connect), External Secrets Operator e RBAC do Azure. A solução elimina a necessidade de armazenar credenciais estáticas, utilizando Workload Identity Federation para autenticação baseada em tokens temporários.

## 📁 Estrutura dos Arquivos

Esta pasta contém os seguintes arquivos e diretórios:

### 📄 Arquivos de Documentação
- **[`external-secret.yaml`](external-secret.yaml)** - Exemplo de configuração do ExternalSecret para sincronizar segredos
- **[`secret-store.yaml`](secret-store.yaml)** - Exemplo de configuração do SecretStore para conectar ao Azure Key Vault
- **[`service-account.yaml`](service-account.yaml)** - Exemplo de ServiceAccount com anotações para Workload Identity

### 📂 Diretórios
- **[`AKS/`](AKS/)** - Contém versões específicas dos guias:
  - [`README-Windows.md`](AKS/README-Windows.md) - Guia para uso no Windows/Powershell
  - [`README-Linux.md`](AKS/README-Linux.md) - Guia para uso no Linux/Bash
- **[`infra-secrets/`](infra-secrets/)** - Terraform para criação do AKV
- **[`OKE/`](OKE/)** - Contém documentação específica para Oracle Kubernetes Engine (OKE):
  - [`README.md`](OKE/README.md) - Guia para configuração do OIDC no OKE (Oracle Cloud)
  - [`cluster-enable-oidc.json`](OKE/cluster-enable-oidc.json) - Configuração JSON para habilitar OIDC no cluster OKE

### 🎯 Propósito dos Arquivos YAML

#### `service-account.yaml`
- **O que faz**: Define uma ServiceAccount no Kubernetes com anotações específicas para Azure Workload Identity
- **Função**: Permite que pods assumam a identidade do Azure AD sem usar secrets estáticos
- **Uso**: Aplicado uma vez no cluster Kubernetes

#### `secret-store.yaml`
- **O que faz**: Configura uma conexão entre o External Secrets Operator e o Azure Key Vault
- **Função**: Define como o operador deve se autenticar e acessar o Key Vault
- **Uso**: Define a fonte dos secrets (Azure Key Vault)

#### `external-secret.yaml`
- **O que faz**: Especifica quais secrets do Key Vault devem ser sincronizados para o Kubernetes
- **Função**: Cria um mapeamento entre secrets do Azure e secrets do Kubernetes
- **Uso**: Aplicado para cada secret que você quer sincronizar

### 🚀 Fluxo de Uso

1. **Leia a documentação**: Comece com este `README.md` para Windows ou `AKS/README-Linux.md` para Linux
2. **Configure a infraestrutura**: Siga os passos para criar recursos no Azure
3. **Aplique os YAMLs**: Use os arquivos de exemplo como base para suas configurações
4. **Teste a sincronização**: Verifique se os secrets estão sendo sincronizados corretamente