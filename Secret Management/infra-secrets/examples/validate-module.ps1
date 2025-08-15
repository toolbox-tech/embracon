# ===============================================
# Teste de Validação: Módulo Email-to-Principal-ID (PowerShell)
# ===============================================
# Este script testa e valida o módulo Terraform
# para conversão de email para principal_id

param(
    [switch]$Verbose
)

# Cores para output
$Colors = @{
    Red    = "Red"
    Green  = "Green"
    Yellow = "Yellow"
    Blue   = "Blue"
    Cyan   = "Cyan"
}

# Função para logging
function Write-Log {
    param([string]$Message, [string]$Color = "Blue")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# ===============================================
# Pré-requisitos e Validações
# ===============================================

Write-Log "Iniciando validação do módulo Terraform Email-to-Principal-ID..."

# Verificar se estamos no diretório correto
if (-not (Test-Path "key-vault-with-email-users.tf")) {
    Write-Error "Arquivo key-vault-with-email-users.tf não encontrado!"
    Write-Error "Execute este script no diretório examples/"
    exit 1
}

Write-Success "Diretório examples encontrado"

# Verificar Terraform
try {
    $terraformVersion = (terraform version -json | ConvertFrom-Json).terraform_version
    Write-Success "Terraform encontrado (versão: $terraformVersion)"
} catch {
    Write-Error "Terraform não está instalado ou não está no PATH"
    exit 1
}

# Verificar Azure CLI
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Success "Azure CLI encontrado (versão: $($azVersion.'azure-cli'))"
} catch {
    Write-Error "Azure CLI não está instalado ou não está no PATH"
    exit 1
}

# Verificar se está logado no Azure
try {
    $azureAccount = az account show --query name -o tsv
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Azure CLI autenticado (conta: $azureAccount)"
    } else {
        throw "Não autenticado"
    }
} catch {
    Write-Error "Não está logado no Azure. Execute: az login"
    exit 1
}

# ===============================================
# Validação da Configuração
# ===============================================

Write-Log "Validando configuração do Terraform..."

# Verificar se o módulo existe
if (-not (Test-Path "../module" -PathType Container)) {
    Write-Error "Diretório ../module não encontrado!"
    exit 1
}

Write-Success "Módulo encontrado em ../module"

# Verificar arquivos essenciais do módulo
$essentialFiles = @("main.tf", "variables.tf", "outputs.tf")
foreach ($file in $essentialFiles) {
    if (-not (Test-Path "../module/$file")) {
        Write-Error "Arquivo ../module/$file não encontrado!"
        exit 1
    }
}

Write-Success "Arquivos essenciais do módulo verificados"

# ===============================================
# Teste de Inicialização
# ===============================================

Write-Log "Testando inicialização do Terraform..."

try {
    terraform init | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Terraform init executado com sucesso"
    } else {
        throw "Falha no init"
    }
} catch {
    Write-Error "Falha no terraform init"
    terraform init
    exit 1
}

# ===============================================
# Teste de Validação de Sintaxe
# ===============================================

Write-Log "Validando sintaxe do Terraform..."

try {
    terraform validate | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Sintaxe Terraform válida"
    } else {
        throw "Erro de sintaxe"
    }
} catch {
    Write-Error "Erro de sintaxe encontrado"
    terraform validate
    exit 1
}

# ===============================================
# Teste de Formatação
# ===============================================

Write-Log "Verificando formatação do código..."

try {
    terraform fmt -check | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Código está formatado corretamente"
    } else {
        Write-Warning "Código precisa de formatação. Executando terraform fmt..."
        terraform fmt | Out-Null
        Write-Success "Código formatado automaticamente"
    }
} catch {
    Write-Warning "Erro na verificação de formatação"
}

# ===============================================
# Teste de Plan (Dry Run)
# ===============================================

Write-Log "Executando terraform plan (dry run)..."

$planFile = "terraform-plan-$(Get-Date -Format 'yyyyMMdd-HHmmss').tfplan"

try {
    terraform plan -out="$planFile" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Terraform plan executado com sucesso"
        
        # Limpeza
        if (Test-Path $planFile) {
            Remove-Item $planFile
        }
    } else {
        throw "Falha no plan"
    }
} catch {
    Write-Error "Falha no terraform plan"
    terraform plan
    exit 1
}

# ===============================================
# Teste de Variáveis do Módulo
# ===============================================

Write-Log "Verificando variáveis do módulo..."

# Verificar se users_allowed_emails está definida
$variablesContent = Get-Content "../module/variables.tf" -Raw
if ($variablesContent -match "users_allowed_emails") {
    Write-Success "Variável users_allowed_emails encontrada no módulo"
} else {
    Write-Error "Variável users_allowed_emails não encontrada no módulo"
    exit 1
}

# Verificar se data source azuread_user está presente
$mainContent = Get-Content "../module/main.tf" -Raw
if ($mainContent -match 'data "azuread_user"') {
    Write-Success "Data source azuread_user encontrado no módulo"
} else {
    Write-Error "Data source azuread_user não encontrado no módulo"
    exit 1
}

# ===============================================
# Teste de Outputs
# ===============================================

Write-Log "Verificando outputs do módulo..."

# Lista de outputs esperados
$expectedOutputs = @("key_vault_id", "key_vault_uri", "key_vault_name", "users_from_emails", "all_principal_ids")

$outputsContent = Get-Content "../module/outputs.tf" -Raw
foreach ($output in $expectedOutputs) {
    if ($outputsContent -match "output `"$output`"") {
        Write-Success "Output $output encontrado"
    } else {
        Write-Error "Output $output não encontrado no módulo"
        exit 1
    }
}

# ===============================================
# Teste de Sintaxe HCL
# ===============================================

Write-Log "Verificando sintaxe HCL dos arquivos..."

$tfFiles = Get-ChildItem -Filter "*.tf"
foreach ($tfFile in $tfFiles) {
    try {
        terraform fmt -check $tfFile.Name | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Sintaxe HCL válida: $($tfFile.Name)"
        } else {
            Write-Warning "Formatação necessária: $($tfFile.Name)"
        }
    } catch {
        Write-Warning "Erro na verificação de sintaxe: $($tfFile.Name)"
    }
}

# ===============================================
# Teste de Documentação
# ===============================================

Write-Log "Verificando documentação..."

if (Test-Path "README.md") {
    Write-Success "README.md encontrado no diretório examples"
} else {
    Write-Warning "README.md não encontrado no diretório examples"
}

if (Test-Path "../module/TERRAFORM-EMAIL-TO-PRINCIPAL-ID.md") {
    Write-Success "Documentação detalhada encontrada"
} else {
    Write-Warning "Documentação detalhada não encontrada"
}

# ===============================================
# Teste de Dependências
# ===============================================

Write-Log "Verificando dependências..."

# Verificar provider azurerm
if ($mainContent -match "azurerm") {
    Write-Success "Provider azurerm configurado"
} else {
    Write-Error "Provider azurerm não encontrado"
    exit 1
}

# Verificar provider azuread
if ($mainContent -match "azuread") {
    Write-Success "Provider azuread configurado"
} else {
    Write-Error "Provider azuread não encontrado"
    exit 1
}

# ===============================================
# Resumo dos Testes
# ===============================================

Write-Host ""
Write-Log "==================== RESUMO DOS TESTES ====================" -Color Cyan
Write-Success "✅ Terraform instalado e funcional"
Write-Success "✅ Azure CLI autenticado"
Write-Success "✅ Módulo e arquivos essenciais presentes"
Write-Success "✅ Sintaxe Terraform válida"
Write-Success "✅ Terraform plan executado com sucesso"
Write-Success "✅ Variáveis e outputs do módulo verificados"
Write-Success "✅ Providers necessários configurados"

Write-Host ""
Write-Log "🎯 PRÓXIMOS PASSOS:" -Color Cyan
Write-Host "   1. Execute: terraform apply (para criar recursos reais)"
Write-Host "   2. Teste com emails reais do seu Azure AD"
Write-Host "   3. Verifique outputs: terraform output summary"
Write-Host "   4. Limpe recursos: terraform destroy"

Write-Host ""
Write-Success "🚀 Módulo Email-to-Principal-ID está pronto para uso!"

Write-Host ""
Write-Log "==================== INFORMAÇÕES ADICIONAIS ====================" -Color Cyan
Write-Host "📋 Para executar com aplicação real:"
Write-Host "   terraform apply"
Write-Host ""
Write-Host "📊 Para ver resultados:"
Write-Host "   terraform output summary"
Write-Host "   terraform output emails_only_users_processed"
Write-Host "   terraform output mixed_all_principal_ids"
Write-Host ""
Write-Host "🧹 Para limpeza:"
Write-Host "   terraform destroy"
Write-Host ""
Write-Host "📖 Documentação completa:"
Write-Host "   ../module/TERRAFORM-EMAIL-TO-PRINCIPAL-ID.md"
