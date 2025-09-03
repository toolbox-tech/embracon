#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Script para espelhar imagens Docker do Docker Hub para o Azure Container Registry (ACR)

.DESCRIPTION
    Este script busca imagens do Docker Hub (ou outros registros) e as armazena no Azure Container Registry.
    Útil para garantir disponibilidade de imagens e mitigar limites de rate limiting do Docker Hub.

.PARAMETER ConfigFile
    Caminho para o arquivo de configuração JSON com a lista de imagens a serem espelhadas

.PARAMETER AcrName
    Nome do Azure Container Registry

.PARAMETER AcrResourceGroup
    Grupo de recursos do Azure Container Registry

.PARAMETER TargetRepository
    Repositório de destino no ACR (opcional, default: 'mirrors')

.PARAMETER SubscriptionId
    ID da assinatura Azure (opcional, usa a assinatura atual por padrão)

.EXAMPLE
    ./mirror-dockerhub-to-acr.ps1 -ConfigFile ./images.json -AcrName embraconacr -AcrResourceGroup embracon-infra
    
.NOTES
    Autor: Time DevOps & SRE - Embracon
    Data:  Setembro de 2025
    Requer: Az PowerShell module, Azure CLI, Docker
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile,
    
    [Parameter(Mandatory=$true)]
    [string]$AcrName,
    
    [Parameter(Mandatory=$true)]
    [string]$AcrResourceGroup,
    
    [Parameter(Mandatory=$false)]
    [string]$TargetRepository = "mirrors",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = ""
)

# Funções de utilidade
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success($message) {
    Write-ColorOutput Green "✅ $message"
}

function Write-Info($message) {
    Write-ColorOutput Cyan "ℹ️ $message"
}

function Write-Warning($message) {
    Write-ColorOutput Yellow "⚠️ $message"
}

function Write-Error($message) {
    Write-ColorOutput Red "❌ $message"
}

function Test-CommandExists {
    param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) { return $true }
    }
    catch {
        return $false
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
}

# Verifica pré-requisitos
Write-Info "Verificando pré-requisitos..."

$prereqs = @("docker", "az")
$missingPrereqs = @()

foreach ($prereq in $prereqs) {
    if (-not (Test-CommandExists $prereq)) {
        $missingPrereqs += $prereq
    }
}

if ($missingPrereqs.Count -gt 0) {
    Write-Error "Pré-requisitos ausentes: $($missingPrereqs -join ', ')"
    Write-Info "Por favor, instale os pré-requisitos ausentes e tente novamente."
    Write-Info "Docker: https://docs.docker.com/get-docker/"
    Write-Info "Azure CLI: https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli"
    exit 1
}

# Verifica se o arquivo de configuração existe
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Arquivo de configuração não encontrado: $ConfigFile"
    exit 1
}

# Carrega o arquivo de configuração
try {
    $config = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
    Write-Success "Arquivo de configuração carregado com sucesso."
}
catch {
    Write-Error "Erro ao carregar o arquivo de configuração: $_"
    exit 1
}

# Login no Azure se necessário
Write-Info "Verificando login no Azure..."
$azContext = $null
try {
    $azContext = az account show --output json | ConvertFrom-Json
    Write-Success "Logado no Azure como $($azContext.user.name) na assinatura $($azContext.name)"
}
catch {
    Write-Warning "Não logado no Azure. Iniciando processo de login..."
    az login
    $azContext = az account show --output json | ConvertFrom-Json
    Write-Success "Login realizado com sucesso como $($azContext.user.name)"
}

# Define a assinatura se especificada
if ($SubscriptionId -ne "") {
    Write-Info "Definindo assinatura para $SubscriptionId..."
    az account set --subscription $SubscriptionId
    Write-Success "Assinatura definida."
}

# Login no ACR
Write-Info "Efetuando login no ACR $AcrName..."
try {
    az acr login --name $AcrName
    Write-Success "Login no ACR realizado com sucesso."
}
catch {
    Write-Error "Falha ao fazer login no ACR: $_"
    exit 1
}

# Obter URL completo do ACR
$acrLoginServer = az acr show --name $AcrName --resource-group $AcrResourceGroup --query loginServer --output tsv
Write-Info "Login server do ACR: $acrLoginServer"

# Função para espelhar uma imagem
function Mirror-DockerImage {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SourceImage,
        
        [Parameter(Mandatory=$true)]
        [string]$TargetImage
    )
    
    Write-Info "Iniciando espelhamento: $SourceImage -> $TargetImage"
    
    # Baixa a imagem de origem
    Write-Info "Baixando $SourceImage..."
    docker pull $SourceImage
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao baixar a imagem $SourceImage"
        return $false
    }
    
    # Cria tag para a imagem de destino
    Write-Info "Criando tag $TargetImage..."
    docker tag $SourceImage $TargetImage
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao criar tag $TargetImage"
        return $false
    }
    
    # Envia a imagem para o ACR
    Write-Info "Enviando $TargetImage para o ACR..."
    docker push $TargetImage
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao enviar imagem $TargetImage para o ACR"
        return $false
    }
    
    Write-Success "Imagem $SourceImage espelhada com sucesso para $TargetImage"
    return $true
}

# Inicia o espelhamento de imagens
Write-Info "Iniciando processo de espelhamento para $($config.images.Length) imagens..."

$total = $config.images.Length
$success = 0
$failures = 0
$startTime = Get-Date

foreach ($image in $config.images) {
    $sourceImage = "$($image.repository):$($image.tag)"
    $targetRepository = if ($image.targetRepository) { $image.targetRepository } else { $TargetRepository }
    $targetImage = "$acrLoginServer/$targetRepository/$($image.repository.Split('/') | Select-Object -Last 1):$($image.tag)"
    
    $result = Mirror-DockerImage -SourceImage $sourceImage -TargetImage $targetImage
    
    if ($result) {
        $success++
    } else {
        $failures++
    }
}

$endTime = Get-Date
$duration = $endTime - $startTime

# Resumo
Write-Info "`n===== RESUMO DO ESPELHAMENTO ====="
Write-Info "Total de imagens: $total"
Write-Success "Sucessos: $success"
if ($failures -gt 0) {
    Write-Error "Falhas: $failures"
} else {
    Write-Info "Falhas: $failures"
}
Write-Info "Duração: $($duration.ToString('hh\:mm\:ss'))"
Write-Info "================================`n"

if ($failures -gt 0) {
    exit 1
} else {
    exit 0
}
