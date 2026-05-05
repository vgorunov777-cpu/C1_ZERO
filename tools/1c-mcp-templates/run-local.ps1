# Локальный запуск MCP шаблонов без Docker (Python 3.10+).
# При первом запуске скачивает bsl_console с GitHub.
param(
	# Запуск процесса Python без отдельного консольного окна (для автозапуска из Cursor).
	[switch]$Background
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$dataTemplates = Join-Path $PSScriptRoot "data\templates"
if (-not (Test-Path -LiteralPath $dataTemplates)) {
	New-Item -ItemType Directory -Path $dataTemplates -Force | Out-Null
}

$bslRoot = Join-Path $PSScriptRoot "bsl_console"
$pkg = Join-Path $bslRoot "package.json"
if (-not (Test-Path -LiteralPath $pkg)) {
	Write-Host "Скачивание bsl_console (salexdv/bsl_console)..." -ForegroundColor Cyan
	$zipUrl = "https://github.com/salexdv/bsl_console/archive/refs/heads/master.zip"
	$tmpZip = Join-Path $env:TEMP "bsl_console_master_$([guid]::NewGuid().ToString('n')).zip"
	$tmpUnzip = Join-Path $env:TEMP "bsl_console_unzip_$([guid]::NewGuid().ToString('n'))"
	try {
		Invoke-WebRequest -Uri $zipUrl -OutFile $tmpZip -UseBasicParsing
		Expand-Archive -LiteralPath $tmpZip -DestinationPath $tmpUnzip -Force
		$src = Join-Path $tmpUnzip "bsl_console-master\src"
		if (-not (Test-Path -LiteralPath $src)) {
			Write-Error "В архиве не найден bsl_console-master\src"
			exit 1
		}
		if (Test-Path -LiteralPath $bslRoot) { Remove-Item $bslRoot -Recurse -Force }
		Copy-Item -LiteralPath $src -Destination $bslRoot -Recurse -Force
	}
	finally {
		Remove-Item -LiteralPath $tmpZip -Force -ErrorAction SilentlyContinue
		Remove-Item -LiteralPath $tmpUnzip -Recurse -Force -ErrorAction SilentlyContinue
	}
	Write-Host "bsl_console готов." -ForegroundColor Green
}

$pyExe = $null
if (Get-Command py -ErrorAction SilentlyContinue) {
	try {
		$pyExe = (& py -3 -c "import sys; print(sys.executable)" 2>$null | Select-Object -Last 1).Trim()
	}
	catch { }
}
if (-not $pyExe -or -not (Test-Path -LiteralPath $pyExe)) {
	$cmd = Get-Command python -ErrorAction SilentlyContinue
	if ($cmd) { $pyExe = $cmd.Source }
}
if (-not $pyExe -or -not (Test-Path -LiteralPath $pyExe)) {
	Write-Error "Не найден Python 3. Установите Python 3.10+ или py launcher."
	exit 1
}

$mainPy = Join-Path $PSScriptRoot "app\main.py"
$pyPath = Join-Path $PSScriptRoot "app"

Write-Host "Запуск MCP: $pyExe $mainPy" -ForegroundColor Cyan

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $pyExe
$psi.Arguments = "`"$mainPy`""
$psi.WorkingDirectory = $PSScriptRoot
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $Background.IsPresent
$psi.EnvironmentVariables["PYTHONPATH"] = $pyPath
$psi.EnvironmentVariables["TEMPLATES_DIR"] = $dataTemplates
$psi.EnvironmentVariables["BSL_CONSOLE_DIR"] = $bslRoot

$p = [System.Diagnostics.Process]::Start($psi)
Write-Host "PID $($p.Id). UI: http://localhost:8023  MCP: http://localhost:8023/mcp" -ForegroundColor Green
Write-Host "Остановка: Stop-Process -Id $($p.Id)" -ForegroundColor DarkGray
