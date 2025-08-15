#!/usr/bin/env bash

# ===============================================
# Teste de Validação: Módulo Email-to-Principal-ID
# ===============================================
# Este script testa e valida o módulo Terraform
# para conversão de email para principal_id

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# ===============================================
# Pré-requisitos e Validações
# ===============================================

log "Iniciando validação do módulo Terraform Email-to-Principal-ID..."

# Verificar se estamos no diretório correto
if [[ ! -f "key-vault-with-email-users.tf" ]]; then
    error "Arquivo key-vault-with-email-users.tf não encontrado!"
    error "Execute este script no diretório examples/"
    exit 1
fi

success "Diretório examples encontrado"

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    error "Terraform não está instalado ou não está no PATH"
    exit 1
fi

TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
success "Terraform encontrado (versão: $TERRAFORM_VERSION)"

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    error "Azure CLI não está instalado ou não está no PATH"
    exit 1
fi

# Verificar se está logado no Azure
if ! az account show &> /dev/null; then
    error "Não está logado no Azure. Execute: az login"
    exit 1
fi

AZURE_ACCOUNT=$(az account show --query name -o tsv)
success "Azure CLI autenticado (conta: $AZURE_ACCOUNT)"

# ===============================================
# Validação da Configuração
# ===============================================

log "Validando configuração do Terraform..."

# Verificar se o módulo existe
if [[ ! -d "../module" ]]; then
    error "Diretório ../module não encontrado!"
    exit 1
fi

success "Módulo encontrado em ../module"

# Verificar arquivos essenciais do módulo
for file in "main.tf" "variables.tf" "outputs.tf"; do
    if [[ ! -f "../module/$file" ]]; then
        error "Arquivo ../module/$file não encontrado!"
        exit 1
    fi
done

success "Arquivos essenciais do módulo verificados"

# ===============================================
# Teste de Inicialização
# ===============================================

log "Testando inicialização do Terraform..."

if terraform init > /dev/null 2>&1; then
    success "Terraform init executado com sucesso"
else
    error "Falha no terraform init"
    terraform init
    exit 1
fi

# ===============================================
# Teste de Validação de Sintaxe
# ===============================================

log "Validando sintaxe do Terraform..."

if terraform validate > /dev/null 2>&1; then
    success "Sintaxe Terraform válida"
else
    error "Erro de sintaxe encontrado"
    terraform validate
    exit 1
fi

# ===============================================
# Teste de Formatação
# ===============================================

log "Verificando formatação do código..."

if terraform fmt -check > /dev/null 2>&1; then
    success "Código está formatado corretamente"
else
    warning "Código precisa de formatação. Executando terraform fmt..."
    terraform fmt
    success "Código formatado automaticamente"
fi

# ===============================================
# Teste de Plan (Dry Run)
# ===============================================

log "Executando terraform plan (dry run)..."

# Criar arquivo temporário para o plan
PLAN_FILE=$(mktemp /tmp/terraform-plan.XXXXXX)

if terraform plan -out="$PLAN_FILE" > /dev/null 2>&1; then
    success "Terraform plan executado com sucesso"
    
    # Analisar o plan
    RESOURCES_TO_ADD=$(terraform show -json "$PLAN_FILE" | jq '.planned_values.root_module.child_modules | length')
    success "Recursos a serem criados: $RESOURCES_TO_ADD módulos"
    
    # Limpeza
    rm -f "$PLAN_FILE"
else
    error "Falha no terraform plan"
    terraform plan
    exit 1
fi

# ===============================================
# Teste de Variáveis do Módulo
# ===============================================

log "Verificando variáveis do módulo..."

# Verificar se users_allowed_emails está definida
if grep -q "users_allowed_emails" "../module/variables.tf"; then
    success "Variável users_allowed_emails encontrada no módulo"
else
    error "Variável users_allowed_emails não encontrada no módulo"
    exit 1
fi

# Verificar se data source azuread_user está presente
if grep -q "data \"azuread_user\"" "../module/main.tf"; then
    success "Data source azuread_user encontrado no módulo"
else
    error "Data source azuread_user não encontrado no módulo"
    exit 1
fi

# ===============================================
# Teste de Outputs
# ===============================================

log "Verificando outputs do módulo..."

# Lista de outputs esperados
EXPECTED_OUTPUTS=("key_vault_id" "key_vault_uri" "key_vault_name" "users_from_emails" "all_principal_ids")

for output in "${EXPECTED_OUTPUTS[@]}"; do
    if grep -q "output \"$output\"" "../module/outputs.tf"; then
        success "Output $output encontrado"
    else
        error "Output $output não encontrado no módulo"
        exit 1
    fi
done

# ===============================================
# Teste de Sintaxe HCL
# ===============================================

log "Verificando sintaxe HCL dos arquivos..."

for tf_file in *.tf; do
    if [[ -f "$tf_file" ]]; then
        if terraform fmt -check "$tf_file" > /dev/null 2>&1; then
            success "Sintaxe HCL válida: $tf_file"
        else
            warning "Formatação necessária: $tf_file"
        fi
    fi
done

# ===============================================
# Teste de Documentação
# ===============================================

log "Verificando documentação..."

if [[ -f "README.md" ]]; then
    success "README.md encontrado no diretório examples"
else
    warning "README.md não encontrado no diretório examples"
fi

if [[ -f "../module/TERRAFORM-EMAIL-TO-PRINCIPAL-ID.md" ]]; then
    success "Documentação detalhada encontrada"
else
    warning "Documentação detalhada não encontrada"
fi

# ===============================================
# Teste de Dependências
# ===============================================

log "Verificando dependências..."

# Verificar provider azurerm
if grep -q "azurerm" "../module/main.tf"; then
    success "Provider azurerm configurado"
else
    error "Provider azurerm não encontrado"
    exit 1
fi

# Verificar provider azuread
if grep -q "azuread" "../module/main.tf"; then
    success "Provider azuread configurado"
else
    error "Provider azuread não encontrado"
    exit 1
fi

# ===============================================
# Resumo dos Testes
# ===============================================

echo ""
log "==================== RESUMO DOS TESTES ===================="
success "✅ Terraform instalado e funcional"
success "✅ Azure CLI autenticado"
success "✅ Módulo e arquivos essenciais presentes"
success "✅ Sintaxe Terraform válida"
success "✅ Terraform plan executado com sucesso"
success "✅ Variáveis e outputs do módulo verificados"
success "✅ Providers necessários configurados"

echo ""
log "🎯 PRÓXIMOS PASSOS:"
echo "   1. Execute: terraform apply (para criar recursos reais)"
echo "   2. Teste com emails reais do seu Azure AD"
echo "   3. Verifique outputs: terraform output summary"
echo "   4. Limpe recursos: terraform destroy"

echo ""
success "🚀 Módulo Email-to-Principal-ID está pronto para uso!"

echo ""
log "==================== INFORMAÇÕES ADICIONAIS ===================="
echo "📋 Para executar com aplicação real:"
echo "   terraform apply"
echo ""
echo "📊 Para ver resultados:"
echo "   terraform output summary"
echo "   terraform output emails_only_users_processed"
echo "   terraform output mixed_all_principal_ids"
echo ""
echo "🧹 Para limpeza:"
echo "   terraform destroy"
echo ""
echo "📖 Documentação completa:"
echo "   ../module/TERRAFORM-EMAIL-TO-PRINCIPAL-ID.md"
