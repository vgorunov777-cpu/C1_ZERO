# Сборка образа и запуск контейнера MCP шаблонов 1С (порт 8023).
# Запуск: powershell -NoProfile -ExecutionPolicy Bypass -File tools\1c-mcp-templates\run-docker.ps1
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Get-DockerExe {
	$candidates = @(
		(Join-Path $env:ProgramFiles "Docker\Docker\resources\bin\docker.exe"),
		(Join-Path ${env:ProgramFiles(x86)} "Docker\Docker\resources\bin\docker.exe"),
		"docker"
	)
	foreach ($c in $candidates) {
		if ($c -eq "docker") {
			$cmd = Get-Command docker -ErrorAction SilentlyContinue
			if ($cmd) { return $cmd.Source }
		}
		elseif (Test-Path -LiteralPath $c) { return $c }
	}
	return $null
}

$dockerDesktop = @(
	(Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"),
	(Join-Path ${env:ProgramFiles(x86)} "Docker\Docker\Docker Desktop.exe")
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

$docker = Get-DockerExe
if (-not $docker) {
	if ($dockerDesktop) {
		Write-Host "Запуск Docker Desktop..." -ForegroundColor Cyan
		Start-Process $dockerDesktop
		$deadline = (Get-Date).AddMinutes(6)
		while ((Get-Date) -lt $deadline) {
			Start-Sleep -Seconds 5
			$docker = Get-DockerExe
			if ($docker) {
				try {
					& $docker version 2>$null | Out-Null
					if ($LASTEXITCODE -eq 0) { break }
				}
				catch { }
			}
		}
	}
}
$docker = Get-DockerExe
if (-not $docker) {
	Write-Error "Docker не найден. Установите Docker Desktop и дождитесь полного запуска."
	exit 1
}

Write-Host "docker: $docker" -ForegroundColor DarkGray
Write-Host "Сборка образа mcp-templates (первый раз может занять несколько минут)..." -ForegroundColor Cyan
& $docker build -t mcp-templates .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Остановка старого контейнера..." -ForegroundColor Cyan
& $docker rm -f mcp-templates 2>$null

$templatesVol = Join-Path $PWD "data\templates"
if (-not (Test-Path -LiteralPath $templatesVol)) {
	New-Item -ItemType Directory -Path $templatesVol -Force | Out-Null
}

Write-Host "Запуск контейнера на http://localhost:8023 ..." -ForegroundColor Cyan
& $docker run -d `
	--name mcp-templates `
	-p 8023:8023 `
	-v "${templatesVol}:/app/data/templates" `
	-e TEMPLATES_DIR=/app/data/templates `
	--restart unless-stopped `
	mcp-templates
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Готово. UI: http://localhost:8023  MCP: http://localhost:8023/mcp" -ForegroundColor Green
