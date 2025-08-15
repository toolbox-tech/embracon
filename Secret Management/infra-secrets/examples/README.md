# 📁 Exemplos de Uso - Azure Key Vault com Email-to-Principal-ID

Este diretório contém exemplos práticos demonstrando como usar o módulo Terraform Azure Key Vault com as novas funcionalidades de conversão de email para principal_id.

## 📋 Exemplos Disponíveis

### 🔹 `key-vault-with-email-users.tf`
**Demonstra três cenários de uso diferentes:**

1. **Key Vault apenas com emails**
   - Usuarios definidos exclusivamente por email
   - Conversão automática para principal_id
   - Ideal para ambientes onde você conhece apenas os emails

2. **Key Vault combinando principal_ids + emails**
   - Mistura usuários com principal_ids conhecidos
   - Adiciona usuários por email
   - Flexibilidade máxima de configuração

3. **Key Vault tradicional (apenas principal_ids)**
   - Método tradicional usando apenas principal_ids
   - Para comparação e compatibilidade

## 🚀 Como Executar os Exemplos

### **Pré-requisitos:**
- ✅ Azure CLI configurado e autenticado
- ✅ Terraform >= 1.5.0 instalado
- ✅ Permissões para ler usuários do Azure AD
- ✅ Permissões para criar recursos Azure

### **Executar Exemplo:**
```bash
# 1. Navegar para o diretório de exemplos
cd "Secret Management/infra-secrets/examples"

# 2. Inicializar Terraform
terraform init

# 3. Revisar o plano
terraform plan

# 4. Aplicar as mudanças
terraform apply

# 5. Ver outputs específicos
terraform output summary
terraform output emails_only_users_processed
terraform output mixed_all_principal_ids
```

## 📊 Outputs dos Exemplos

### **Summary Output:**
```bash
terraform output summary
```
Exibe resumo comparativo dos três cenários:
```json
{
  "emails_only": {
    "emails_provided": 3,
    "vault_name": "kv-emails-only-abc12345"
  },
  "mixed_users": {
    "direct_principal_ids": 2,
    "emails_converted": 2,
    "total_users": 4,
    "vault_name": "kv-mixed-users-abc12345"
  },
  "traditional": {
    "direct_principal_ids": 3,
    "vault_name": "kv-traditional-abc12345"
  }
}
```

### **Usuários Processados via Email:**
```bash
terraform output emails_only_users_processed
```
Mostra informações detalhadas dos usuários convertidos:
```json
{
  "display_names": [
    "Admin Embracon",
    "DevOps User",
    "João Silva"
  ],
  "emails": [
    "admin@embracon.com.br",
    "devops@empresa.com",
    "joao.silva@empresa.com"
  ],
  "principal_ids": [
    "12345678-90ab-cdef-1234-567890abcdef",
    "87654321-cdef-1234-5678-90abcdef1234",
    "abcdef12-3456-7890-abcd-ef1234567890"
  ]
}
```

### **Todos os Principal IDs (Cenário Misto):**
```bash
terraform output mixed_all_principal_ids
```
Lista completa de todos os principal_ids:
```json
[
  "12345678-1234-1234-1234-123456789012",  # Direto
  "87654321-4321-4321-4321-210987654321",  # Direto
  "abcd1234-5678-90ef-ghij-klmnopqrstuv",  # Convertido de email
  "efgh5678-90ab-cdef-1234-567890abcdef"   # Convertido de email
]
```

## ⚙️ Personalização dos Exemplos

### **Modificar Emails de Teste:**
Edite o arquivo `key-vault-with-email-users.tf` e altere os emails:

```hcl
# Substitua pelos emails reais do seu ambiente
users_allowed_emails = [
  "seu.email@empresa.com",
  "admin@seudominio.com",
  "devops@seudominio.com"
]
```

### **Alterar Configurações do Key Vault:**
```hcl
# Personalize as configurações básicas
key_vault_name      = "seu-keyvault-${random_string.suffix.result}"
location            = "Brazil South"  # ou sua região preferida
resource_group_name = "seu-resource-group"
```

### **Adicionar Tags (se suportado):**
```hcl
# Se o módulo suportar tags no futuro
tags = {
  Environment = "Production"
  Owner       = "DevOps"
  CostCenter  = "TI"
}
```

## 🚨 Troubleshooting

### **❌ "User not found" Error:**
```bash
Error: User with principal name "email@exemplo.com" was not found
```
**Solução:**
- Verifique se o email existe no Azure AD
- Confirme que é o User Principal Name (UPN)
- Use `az ad user list` para verificar usuários disponíveis

### **❌ "Insufficient privileges":**
```bash
Error: Insufficient privileges to complete the operation
```
**Solução:**
```bash
# Verificar permissões atuais
az role assignment list --assignee $(az account show --query user.name -o tsv)

# Solicitar permissões de leitura do Azure AD ao administrador
```

### **❌ "Resource already exists":**
```bash
Error: A resource with the ID already exists
```
**Solução:**
```bash
# Limpar recursos existentes
terraform destroy

# Ou usar suffix aleatório diferente
terraform apply -var="suffix=$(date +%s)"
```

## 🧹 Limpeza

### **Remover todos os recursos criados:**
```bash
terraform destroy
```

### **Verificar remoção completa:**
```bash
# Listar Key Vaults restantes
az keyvault list --resource-group "rg-keyvault-email-example" --output table

# Verificar Resource Group
az group show --name "rg-keyvault-email-example"
```

## 📚 Recursos Relacionados

- 📖 [**Módulo Principal**](../module/README.md) - Documentação do módulo
- 🔧 [**Guia Email-to-Principal-ID**](../module/TERRAFORM-EMAIL-TO-PRINCIPAL-ID.md) - Guia detalhado
- 🏗️ [**README Principal**](../README.md) - Documentação geral da infraestrutura
- 🔐 [**Azure AD User Lookup**](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) - Documentação oficial

---

<p align="center">
  <strong>🎯 Exemplos Práticos para Conversão Email → Principal ID</strong><br>
  <em>Aprenda na prática como usar a nova funcionalidade</em>
</p>
