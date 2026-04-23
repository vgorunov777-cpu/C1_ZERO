# Автозапуск локальных HTTP MCP при открытии workspace (runOn: folderOpen).
# 1c-forms-mcp :8011; 1c-templates :8023; trusted-gateway :8767 (если задан путь к exe).
# 1c-bsl-help — stdio через cmd+java (см. tools/1c-bsl-help).
$ErrorActionPreference = "Continue"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$formsAuto = Join-Path $PSScriptRoot "start-1c-forms-auto.ps1"
if (Test-Path -LiteralPath $formsAuto) {
	try {
		& $formsAuto
	}
	catch {
		Write-Host "start-1c-forms-auto: $($_.Exception.Message)" -ForegroundColor DarkYellow
	}
}

$templatesAuto = Join-Path $PSScriptRoot "start-1c-templates-auto.ps1"
if (Test-Path -LiteralPath $templatesAuto) {
	try {
		& $templatesAuto
	}
	catch {
		Write-Host "start-1c-templates-auto: $($_.Exception.Message)" -ForegroundColor DarkYellow
	}
}

$gatewayAuto = Join-Path $workspaceRoot "tools\trusted-gateway\start-trusted-gateway-auto.ps1"
if (Test-Path -LiteralPath $gatewayAuto) {
	try {
		& $gatewayAuto
	}
	catch {
		Write-Host "start-trusted-gateway-auto: $($_.Exception.Message)" -ForegroundColor DarkYellow
	}
}
