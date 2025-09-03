#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Script para verificar vulnerabilidades e atualizações de segurança em imagens Docker

.DESCRIPTION
    Este script analisa as imagens Docker da sua lista de espelhamento e verifica se existem
    vulnerabilidades conhecidas ou atualizações de segurança disponíveis.

.PARAMETER ConfigFile
    Caminho para o arquivo de configuração JSON com a lista de imagens a serem analisadas

.PARAMETER OutputFile
    Caminho para o arquivo de saída do relatório em formato JSON

.PARAMETER OutputFormat
    Formato de saída do relatório (JSON, CSV, Markdown)

.EXAMPLE
    ./scan-docker-vulnerabilities.ps1 -ConfigFile ./docker-images.json -OutputFile ./vulnerabilities-report.md -OutputFormat Markdown
    
.NOTES
    Autor: Time DevOps & SRE - Embracon
    Data:  Setembro de 2025
    Requer: Az PowerShell module, trivy
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "./docker-vulnerabilities-report.json",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("JSON", "CSV", "Markdown")]
    [string]$OutputFormat = "JSON"
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

if (-not (Test-CommandExists "trivy")) {
    Write-Error "Ferramenta 'trivy' não encontrada. Por favor instale: https://github.com/aquasecurity/trivy#installation"
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

# Função para escanear uma imagem
function Scan-DockerImage {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Image
    )
    
    Write-Info "Escaneando $Image..."
    
    try {
        # Primeiro vamos baixar a imagem
        docker pull $Image 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Falha ao baixar a imagem $Image. Tentando escanear remotamente..."
        }

        # Agora escaneamos com o Trivy
        $scanOutput = trivy image --format json $Image
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Falha ao escanear a imagem $Image"
            return $null
        }

        $scanResult = $scanOutput | ConvertFrom-Json
        return $scanResult
    }
    catch {
        Write-Error "Erro ao escanear a imagem $Image: $_"
        return $null
    }
}

# Cria resultado
$results = @{
    scanDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    images = @()
}

# Inicia o escaneamento de imagens
Write-Info "Iniciando processo de escaneamento para $($config.images.Length) imagens..."

$total = $config.images.Length
$success = 0
$failures = 0
$startTime = Get-Date

foreach ($image in $config.images) {
    $imageTag = "$($image.repository):$($image.tag)"
    
    $scanResult = Scan-DockerImage -Image $imageTag
    
    if ($scanResult) {
        $success++
        
        # Processa os resultados para uma estrutura simplificada
        $vulnerabilities = @{
            critical = 0
            high = 0
            medium = 0
            low = 0
            unknown = 0
        }
        
        # Conta as vulnerabilidades por severidade
        foreach ($result in $scanResult.Results) {
            if ($result.Vulnerabilities) {
                foreach ($vuln in $result.Vulnerabilities) {
                    switch ($vuln.Severity) {
                        "CRITICAL" { $vulnerabilities.critical++ }
                        "HIGH" { $vulnerabilities.high++ }
                        "MEDIUM" { $vulnerabilities.medium++ }
                        "LOW" { $vulnerabilities.low++ }
                        default { $vulnerabilities.unknown++ }
                    }
                }
            }
        }
        
        # Adiciona aos resultados
        $imageResult = @{
            image = $imageTag
            description = $image.description
            vulnerabilities = $vulnerabilities
            scanSuccessful = $true
            details = $scanResult
        }
        
        $results.images += $imageResult
        
        # Exibe resultado
        if ($vulnerabilities.critical -gt 0 -or $vulnerabilities.high -gt 0) {
            Write-Warning "Imagem $imageTag: $($vulnerabilities.critical) críticas, $($vulnerabilities.high) altas, $($vulnerabilities.medium) médias, $($vulnerabilities.low) baixas"
        } else {
            Write-Success "Imagem $imageTag: $($vulnerabilities.critical) críticas, $($vulnerabilities.high) altas, $($vulnerabilities.medium) médias, $($vulnerabilities.low) baixas"
        }
    } else {
        $failures++
        $results.images += @{
            image = $imageTag
            description = $image.description
            scanSuccessful = $false
            error = "Falha ao escanear imagem"
        }
    }
}

$endTime = Get-Date
$duration = $endTime - $startTime

# Salva resultado no formato escolhido
switch ($OutputFormat) {
    "JSON" {
        $results | ConvertTo-Json -Depth 10 | Out-File $OutputFile
    }
    "CSV" {
        $csvOutput = @()
        foreach ($imageResult in $results.images) {
            $csvOutput += [PSCustomObject]@{
                Image = $imageResult.image
                Description = $imageResult.description
                Critical = if ($imageResult.scanSuccessful) { $imageResult.vulnerabilities.critical } else { "N/A" }
                High = if ($imageResult.scanSuccessful) { $imageResult.vulnerabilities.high } else { "N/A" }
                Medium = if ($imageResult.scanSuccessful) { $imageResult.vulnerabilities.medium } else { "N/A" }
                Low = if ($imageResult.scanSuccessful) { $imageResult.vulnerabilities.low } else { "N/A" }
                Unknown = if ($imageResult.scanSuccessful) { $imageResult.vulnerabilities.unknown } else { "N/A" }
                ScanSuccessful = $imageResult.scanSuccessful
                Error = $imageResult.error
            }
        }
        $csvOutput | Export-Csv -Path $OutputFile -NoTypeInformation
    }
    "Markdown" {
        $md = "# Relatório de Vulnerabilidades - Imagens Docker`n`n"
        $md += "Gerado em: $($results.scanDate)`n`n"
        
        $md += "## Resumo`n`n"
        $md += "| Métrica | Valor |`n"
        $md += "| --- | --- |`n"
        $md += "| Total de imagens | $total |`n"
        $md += "| Escaneamentos com sucesso | $success |`n"
        $md += "| Falhas | $failures |`n"
        $md += "| Duração | $($duration.ToString('hh\:mm\:ss')) |`n`n"
        
        $md += "## Resultados por Imagem`n`n"
        $md += "| Imagem | Críticas | Altas | Médias | Baixas | Status |`n"
        $md += "| --- | :---: | :---: | :---: | :---: | --- |`n"
        
        foreach ($imageResult in $results.images) {
            if ($imageResult.scanSuccessful) {
                $v = $imageResult.vulnerabilities
                $status = if ($v.critical -gt 0 -or $v.high -gt 0) { "⚠️ Ação Necessária" } else { "✅ OK" }
                $md += "| $($imageResult.image) | $($v.critical) | $($v.high) | $($v.medium) | $($v.low) | $status |`n"
            } else {
                $md += "| $($imageResult.image) | - | - | - | - | ❌ Falha no escaneamento |`n"
            }
        }
        
        $md | Out-File -FilePath $OutputFile
    }
}

# Resumo
Write-Info "`n===== RESUMO DO ESCANEAMENTO ====="
Write-Info "Total de imagens: $total"
Write-Success "Sucessos: $success"
if ($failures -gt 0) {
    Write-Error "Falhas: $failures"
} else {
    Write-Info "Falhas: $failures"
}
Write-Info "Duração: $($duration.ToString('hh\:mm\:ss'))"
Write-Info "Relatório salvo em: $OutputFile"
Write-Info "================================`n"

if ($failures -gt 0) {
    exit 1
} else {
    exit 0
}
