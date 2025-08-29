<p align="center">
  <img src="../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# 🛠️ Ferramentas Kubernetes (Kubernetes Tools)

Bem-vindo à coleção de ferramentas, utilitários e guias para facilitar a administração e operação de clusters Kubernetes na Embracon. Este repositório contém soluções prontas para uso e documentação detalhada para implementações comuns.

## 📋 Índice

- [🔍 Visão Geral](#-visão-geral)
- [📁 Estrutura do Repositório](#-estrutura-do-repositório)
- [⚙️ Ferramentas Disponíveis](#️-ferramentas-disponíveis)
  - [📊 Kubernetes Dashboard](#-kubernetes-dashboard)
  - [🔐 Keycloak](#-keycloak)
- [🚀 Como Usar](#-como-usar)
- [🧪 Testes e Validações](#-testes-e-validações)
- [👥 Contribuição](#-contribuição)
- [📝 Notas Importantes](#-notas-importantes)

## 🔍 Visão Geral

O diretório `kubernetes-tools` foi criado para centralizar ferramentas e soluções que complementam as funcionalidades básicas do Kubernetes, oferecendo:

- **Interfaces de gerenciamento visual** (Kubernetes Dashboard)
- **Soluções de autenticação e autorização** (Keycloak)
- **Guias detalhados de implementação**
- **Configurações RBAC pré-definidas**
- **Melhores práticas de segurança**

Todas as ferramentas foram testadas em ambientes AKS (Azure Kubernetes Service) e seguem as melhores práticas de segurança e configuração.

## 📁 Estrutura do Repositório

```
kubernetes-tools/
├── README.md                   # Este arquivo
├── dashboard/                  # Kubernetes Dashboard e configurações RBAC
│   ├── README.md               # Documentação completa do Dashboard
│   ├── dashboard-admin-user.yaml           # ServiceAccount com acesso admin
│   ├── dashboard-readonly-user.yaml        # ServiceAccount com acesso somente leitura
│   ├── dev-namespace-only-user.yaml        # ServiceAccount com acesso a namespace específica
│   ├── entra-id-dashboard-rbac.yaml        # Configuração RBAC para grupos Azure AD (admin)
│   ├── entra-id-readonly-rbac.yaml         # Configuração RBAC para grupos Azure AD (readonly)
│   ├── entra-id.md                         # Guia de integração com Microsoft Entra ID
│   └── kubernetes-roles-guide.md           # Guia completo de Roles e ClusterRoles
└── keycloak/                  # Keycloak para autenticação
    ├── README.md               # Documentação do Keycloak
    └── helm-chart/             # Helm chart para implantação do Keycloak
```

## ⚙️ Ferramentas Disponíveis

### 📊 Kubernetes Dashboard

O [Kubernetes Dashboard](./dashboard/README.md) é uma interface de usuário web para administração de clusters Kubernetes. Nossa implementação inclui:

- **Instalação segura** via Helm chart com Kong como proxy
- **Configurações RBAC** para diferentes perfis de usuário:
  - Administradores (acesso completo)
  - Desenvolvedores (acesso a namespaces específicos)
  - Leitores (acesso somente-leitura ao cluster)
- **Integração com Microsoft Entra ID** (Azure AD)
- **Exposição segura** via Ingress ou LoadBalancer
- **Autenticação por token** com service accounts dedicadas

#### 🔍 Recursos Destacados

- ✅ Guia completo de instalação e configuração
- ✅ Arquivos YAML prontos para uso
- ✅ Instruções de teste e validação
- ✅ Melhores práticas de segurança
- ✅ Troubleshooting para problemas comuns

### 🔐 Keycloak

O [Keycloak](./keycloak/README.md) é uma solução de gerenciamento de identidade e acesso (IAM) que pode ser integrada ao Kubernetes para autenticação centralizada. Nossa implementação inclui:

- **Instalação via Helm** com valores otimizados
- **Configuração para integração com Kubernetes**
- **Modelo de realms e clientes pré-configurados**
- **Fluxos de autenticação OIDC**
- **Alta disponibilidade** e persistência

## 🚀 Como Usar

Cada subdiretório contém seu próprio README.md com instruções detalhadas de instalação, configuração e uso. Para começar:

1. Navegue até o diretório da ferramenta desejada
2. Siga o guia de instalação no README.md correspondente
3. Utilize os arquivos YAML fornecidos como base para sua implementação
4. Execute os testes recomendados para validar a configuração

## 🧪 Testes e Validações

Recomendamos testar as ferramentas em um ambiente de desenvolvimento antes de aplicá-las em produção. Cada ferramenta inclui seções específicas de validação.

Para o Dashboard:
```bash
# Verificar se o pod do Dashboard está em execução
kubectl get pods -n kubernetes-dashboard

# Validar configurações RBAC
kubectl auth can-i "*" "*" --as=system:serviceaccount:kubernetes-dashboard:admin-user
```

Para o Keycloak:
```bash
# Verificar se o pod do Keycloak está em execução
kubectl get pods -n keycloak

# Validar acesso à interface web
kubectl port-forward svc/keycloak 8080:8080 -n keycloak
# Acesse http://localhost:8080 em seu navegador
```

## 👥 Contribuição

Sua contribuição é bem-vinda! Para adicionar novas ferramentas ou melhorar as existentes:

1. Crie um branch com o nome da ferramenta ou melhoria
2. Adicione a ferramenta em seu próprio subdiretório
3. Inclua um README.md detalhado com instruções
4. Documente casos de uso, limitações e melhores práticas
5. Abra um Pull Request para revisão

## 📝 Notas Importantes

- As ferramentas são testadas principalmente em AKS (Azure Kubernetes Service)
- Ajustes podem ser necessários para outros provedores (EKS, GKE, etc.)
- Siga sempre as melhores práticas de segurança ao implementar estas ferramentas
- Mantenha as ferramentas e configurações atualizadas para evitar vulnerabilidades

---

<p align="center">
  <img src="../img/toolbox-footer.png" alt="Toolbox Footer" width="200"/>
  <br />
  <em>Desenvolvido pelo Time de DevOps & SRE - Embracon</em>
</p>
