<p align="center">
  <img src="../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# 🗝️ Guia para acessar um segredo no Azure Key Vault (AKV) usando OIDC

Este guia apresenta um passo a passo para acessar segredos do Azure Key Vault (AKV) de forma segura usando OIDC (OpenID Connect), External Secrets Operator e RBAC do Azure. A solução elimina a necessidade de armazenar credenciais estáticas, utilizando Workload Identity Federation para autenticação baseada em tokens temporários.

## 📁 Estrutura dos Arquivos

Esta pasta contém os seguintes arquivos e diretórios:

### 📄 Arquivos de Documentação
- **[`external-secret.yaml`](external-secret.yaml)** - Exemplo de configuração do ExternalSecret para sincronizar segredos
- **[`secret-store.yaml`](secret-store.yaml)** - Exemplo de configuração do SecretStore para conectar ao Azure Key Vault
- **[`service-account.yaml`](service-account.yaml)** - Exemplo de ServiceAccount com anotações para Workload Identity

### 📂 Diretórios
- **[`AKS/`](AKS/)** - Contém documentação específica para Azure Kubernetes Service (AKS):
  - [`README.md`](AKS/README.md) - Visão geral da solução com diagramas arquiteturais
  - [`README-Linux.md`](AKS/README-Linux.md) - Guia completo para configuração OIDC no AKS (Linux/macOS)
  - [`README-Windows.md`](AKS/README-Windows.md) - Guia completo para configuração OIDC no AKS (Windows)
- **[`infra-secrets/`](infra-secrets/)** - Contém código Terraform para criação e gestão do Azure Key Vault:
  - [`README.md`](infra-secrets/README.md) - Documentação geral do diretório Terraform
  - **[`module/`](infra-secrets/module/)** - Módulo Terraform reutilizável para Azure Key Vault:
    - [`README.md`](infra-secrets/module/README.md) - Documentação completa do módulo Terraform
    - [`main.tf`](infra-secrets/module/main.tf) - Recursos principais do Azure Key Vault
    - [`variables.tf`](infra-secrets/module/variables.tf) - Variáveis de entrada do módulo
    - [`outputs.tf`](infra-secrets/module/outputs.tf) - Outputs do módulo (URLs, IDs, etc.)
  - **[`resource/`](infra-secrets/resource/)** - Exemplo de uso do módulo Terraform:
    - [`main.tf`](infra-secrets/resource/main.tf) - Implementação de exemplo usando o módulo
    - [`provider.tf`](infra-secrets/resource/provider.tf) - Configuração do provider Azure
    - [`variables.tf`](infra-secrets/resource/variables.tf) - Variáveis do ambiente de exemplo
- **[`OKE/`](OKE/)** - Contém documentação específica para Oracle Kubernetes Engine (OKE):
  - [`README.md`](OKE/README.md) - Guia para configuração do OIDC no OKE (Oracle Cloud)
  - [`cluster-enable-oidc.json`](OKE/cluster-enable-oidc.json) - Configuração JSON para habilitar OIDC no cluster OKE

### 🎯 Propósito dos Arquivos YAML

#### `service-account.yaml`
- **O que faz**: Define uma ServiceAccount no Kubernetes com anotações específicas para Azure Workload Identity
- **Função**: Permite que pods assumam a identidade do Azure AD sem usar secrets estáticos
- **Uso**: Aplicado uma vez no cluster Kubernetes
- **Observação**: Para usar mais de um identidade, crie múltiplos recursos `ServiceAccount` com as anotações apropriadas para cada identidade desejada.

#### `secret-store.yaml`
- **O que faz**: Configura uma conexão entre o External Secrets Operator e o Azure Key Vault. A ideia por trás do recurso `SecretStore` é separar as responsabilidades de autenticação/acesso da configuração e dos próprios segredos utilizados pelas aplicações. O `ExternalSecret` define **o que** buscar, enquanto o `SecretStore` define **como** acessar. Este recurso é do tipo namespaced, ou seja, pertence a um namespace específico no Kubernetes.
- **Função**: Define como o operador deve se autenticar e acessar o Key Vault
- **Uso**: Define a fonte dos secrets (Azure Key Vault)
- **Observação**: Para usar mais de uma fonte de secrets, crie múltiplos recursos `SecretStore`.

#### `external-secret.yaml`
- **O que faz**: Especifica quais secrets do Key Vault devem ser sincronizados para o Kubernetes
- **Função**: Cria um mapeamento entre secrets do Azure e secrets do Kubernetes
- **Uso**: Aplicado para cada secret que você quer sincronizar
- **Observação**: Para usar mais de um secret, crie múltiplos recursos `ExternalSecret` apontando para diferentes secrets do Key Vault conforme necessário.

### 🚀 Fluxo de Uso

1. **Leia a documentação**: Comece com este `README.md` para Windows ou `AKS/README-Linux.md` para Linux
2. **Configure a infraestrutura**: Siga os passos para criar recursos no Azure
3. **Aplique os YAMLs**: Use os arquivos de exemplo como base para suas configurações
4. **Teste a sincronização**: Verifique se os secrets estão sendo sincronizados corretamente

---

<p align="center">
  <strong>🚀 Secret Management 🛡️</strong><br>
    <em>🔐 Azure Key Vault e OIDC</em>
</p>