# 📋 Changelog - Azure Key Vault Terraform Module

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-01-XX

### 🎉 Adicionado
- **Nova funcionalidade:** Conversão automática de email para principal_id
- **Variável `users_allowed_emails`:** Lista de emails para conversão automática
- **Data source `azuread_user`:** Lookup de usuários por email no Azure AD
- **Output `users_from_emails`:** Informações detalhadas dos usuários convertidos
- **Output `all_principal_ids`:** Lista combinada de todos os principal IDs
- **Output `direct_principal_ids`:** Principal IDs fornecidos diretamente
- **Documentação completa:** `TERRAFORM-EMAIL-TO-PRINCIPAL-ID.md`
- **Exemplos práticos:** Pasta `examples/` com casos de uso reais
- **Scripts de validação:** `validate-module.sh` e `validate-module.ps1`
- **Locals block:** Combinação inteligente de principal IDs diretos + convertidos

### 🔄 Modificado
- **`main.tf`:** Adicionado data source para lookup de usuários
- **`variables.tf`:** Nova variável `users_allowed_emails` com validação
- **`outputs.tf`:** Expandido com outputs detalhados para auditoria
- **README.md:** Atualizado com documentação das novas funcionalidades
- **Exemplos de uso:** Atualizados para mostrar funcionalidades combinadas

### 🛡️ Segurança
- **Validação de entrada:** Verificação de formato de email
- **Tratamento de erros:** Mensagens claras para usuários não encontrados
- **Princípio de menor privilégio:** Apenas permissões necessárias para Azure AD

### 📖 Documentação
- **Guia detalhado:** Como usar email-to-principal-id conversion
- **Exemplos práticos:** Três cenários diferentes de uso
- **Troubleshooting:** Soluções para problemas comuns
- **Scripts de teste:** Validação automatizada do módulo

### ⚡ Performance
- **Lookup eficiente:** Data source otimizado para múltiplos usuários
- **Combinação inteligente:** Evita duplicação de principal IDs

## [1.0.0] - 2024-01-XX

### 🎉 Versão Inicial
- **Azure Key Vault:** Criação e configuração básica
- **RBAC:** Permissões baseadas em principal IDs
- **Variáveis básicas:** `key_vault_name`, `location`, `resource_group_name`
- **Outputs básicos:** `key_vault_id`, `key_vault_uri`, `key_vault_name`
- **Provider Azure:** Configuração para azurerm
- **Documentação:** README básico com instruções de uso

### 🔧 Funcionalidades Base
- **Key Vault creation:** Com configurações padrão de segurança
- **Resource Group:** Integração com RG existente
- **SKU configuration:** Standard por padrão, personalizável
- **Basic RBAC:** Suporte para principal IDs conhecidos

---

## 🔮 Roadmap - Próximas Versões

### [2.1.0] - Planejado
- **Suporte a grupos:** Conversão de grupos por nome/email
- **Validação avançada:** Verificação de domínio de email
- **Cache de lookup:** Otimização para grandes quantidades de usuários
- **Políticas de acesso:** Configuração granular por secret/key

### [2.2.0] - Planejado
- **Multi-tenant:** Suporte para lookup em múltiplos tenants
- **Bulk operations:** Importação em massa de usuários por CSV
- **Auditoria avançada:** Logs detalhados de todas as operações
- **Integração externa:** APIs para sincronização com sistemas externos

### [3.0.0] - Futuro
- **Breaking changes:** Reorganização de variáveis e outputs
- **Módulos compostos:** Sub-módulos para diferentes cenários
- **Terraform 1.7+:** Recursos mais recentes do Terraform
- **Provider updates:** Compatibilidade com versões mais recentes

---

## 📝 Notas de Migração

### Migração 1.0.x → 2.0.0

#### ✅ Compatibilidade Backward
Esta versão mantém **100% de compatibilidade** com a versão anterior:
- Todas as variáveis existentes funcionam normalmente
- Outputs existentes permanecem inalterados
- Comportamento padrão não foi alterado

#### 🆕 Para Usar Novas Funcionalidades
```hcl
# Adicione estas variáveis opcionais ao seu código existente
module "key_vault" {
  # ... configuração existente ...
  
  # NOVO: Usuários por email (opcional)
  users_allowed_emails = [
    "admin@empresa.com",
    "devops@empresa.com"
  ]
}

# NOVO: Outputs adicionais disponíveis
output "usuarios_convertidos" {
  value = module.key_vault.users_from_emails
}
```

#### 🔧 Sem Mudanças Necessárias
- ✅ Código existente funciona sem modificações
- ✅ Mesmos outputs disponíveis
- ✅ Mesmas permissões necessárias
- ✅ Compatível com mesmo Terraform version

---

## 🤝 Contribuindo

### Como Reportar Issues
1. Verifique se o issue já existe
2. Use templates de issue apropriados
3. Inclua informações de versão do Terraform e Azure CLI
4. Anexe logs relevantes (sem informações sensíveis)

### Como Contribuir com Código
1. Fork o repositório
2. Crie uma branch para sua feature
3. Adicione testes para novas funcionalidades
4. Execute scripts de validação
5. Submeta um Pull Request

### Padrões de Qualidade
- ✅ Terraform fmt aplicado
- ✅ Terraform validate passou
- ✅ Documentação atualizada
- ✅ Exemplos funcionais incluídos
- ✅ Scripts de teste executados

---

## 📞 Suporte

### 📧 Contato
- **Issues:** Use GitHub Issues para bugs e feature requests
- **Discussões:** GitHub Discussions para dúvidas gerais
- **Documentação:** Consulte README.md e docs/ folder

### 🔍 Troubleshooting
1. Verifique a documentação mais recente
2. Execute scripts de validação incluídos
3. Consulte seção troubleshooting no README
4. Verifique issues conhecidos no GitHub

---

<p align="center">
  <strong>🚀 Azure Key Vault Terraform Module</strong><br>
  <em>Infraestrutura como Código com Segurança e Flexibilidade</em>
</p>
