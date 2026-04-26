# Отложенная проверка и автозапуск HTTP MCP-сервисов.
# Вызывается через VS Code task (runOn: folderOpen) — срабатывает при открытии workspace.
# Логика: подождать 60 сек, затем проверить порты 8011 и 8023, запустить отсутствующие.
$ErrorActionPreference = "Continue"

$FormsPort = 8011
$TemplatesPort = 8023

function Test-TcpPort {
	param([int]$Port)
	$client = New-Object System.Net.Sockets.TcpClient
	try {
		$async = $client.BeginConnect("127.0.0.1", $Port, $null, $null)
		if (-not $async.AsyncWaitHandle.WaitOne(800, $false)) {
			return $false
		}
		$client.EndConnect($async)
		return $client.Connected
	}
	catch {
		return $false
	}
	finally {
		if ($client) {
			$client.Close()
		}
	}
}

function Start-McpService {
	param(
		[string]$Name,
		[int]$Port,
		[string]$ScriptPath
	)

	if (Test-TcpPort -Port $Port) {
		Write-Host "[$Name] OK — порт $Port уже слушается" -ForegroundColor Green
		return
	}

	if (-not (Test-Path -LiteralPath $ScriptPath)) {
		Write-Host "[$Name] ПРОПУСК — скрипт не найден: $ScriptPath" -ForegroundColor DarkYellow
		return
	}

	Write-Host "[$Name] Порт $Port не доступен — запуск..." -ForegroundColor Cyan

	$psi = New-Object System.Diagnostics.ProcessStartInfo
	$psi.FileName = "powershell.exe"
	$psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" -Background"
	$psi.UseShellExecute = $false
	$psi.CreateNoWindow = $true

	try {
		$p = [System.Diagnostics.Process]::Start($psi)
		Write-Host "[$Name] Запущен PID $($p.Id)" -ForegroundColor Green
	}
	catch {
		Write-Host "[$Name] ОШИБКА запуска: $($_.Exception.Message)" -ForegroundColor Red
	}
}

# --- Основная логика ---

Write-Host "MCP Health Check: ожидание 60 сек перед проверкой..." -ForegroundColor DarkGray
Start-Sleep -Seconds 60

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$timestamp = Get-Date -Format "HH:mm:ss"
Write-Host "[$timestamp] Проверка MCP-сервисов..." -ForegroundColor Cyan

$formsScript = Join-Path $workspaceRoot "tools\1c-formsserver\run-local.ps1"
$templatesScript = Join-Path $workspaceRoot "tools\1c-mcp-templates\run-local.ps1"

Start-McpService -Name "1c-forms-mcp" -Port $FormsPort -ScriptPath $formsScript
Start-McpService -Name "1c-templates" -Port $TemplatesPort -ScriptPath $templatesScript

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Проверка завершена." -ForegroundColor Cyan
