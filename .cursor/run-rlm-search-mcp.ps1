# Запуск MCP rlm-bsl-search для Cursor (Windows): venv + pip install -e в tools/rlm-bsl-search.
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$rlmRoot = Join-Path $repoRoot "tools\rlm-bsl-search"
if (-not (Test-Path -LiteralPath $rlmRoot)) {
	Write-Error "Не найден каталог: $rlmRoot"
	exit 1
}

$venvPath = Join-Path $rlmRoot ".venv"
$venvPy = Join-Path $venvPath "Scripts\python.exe"

if (-not (Test-Path -LiteralPath $venvPy)) {
	if (Get-Command py -ErrorAction SilentlyContinue) {
		& py -3.12 -m venv $venvPath 2>$null
	}
	if (-not (Test-Path -LiteralPath $venvPy)) {
		if (Get-Command py -ErrorAction SilentlyContinue) {
			& py -3.11 -m venv $venvPath 2>$null
		}
	}
	if (-not (Test-Path -LiteralPath $venvPy)) {
		if (Get-Command py -ErrorAction SilentlyContinue) {
			& py -3.10 -m venv $venvPath 2>$null
		}
	}
	if (-not (Test-Path -LiteralPath $venvPy)) {
		if (Get-Command py -ErrorAction SilentlyContinue) {
			& py -3 -m venv $venvPath
		}
	}
	if (-not (Test-Path -LiteralPath $venvPy)) {
		$python = Get-Command python -ErrorAction SilentlyContinue
		if ($python) {
			& $python.Source -m venv $venvPath
		}
	}
	if (-not (Test-Path -LiteralPath $venvPy)) {
		Write-Error "Не удалось создать .venv. Установите Python 3.10+ (py или python в PATH)."
		exit 1
	}
	$pip = Join-Path $venvPath "Scripts\pip.exe"
	& $pip install -e $rlmRoot
}

& $venvPy -m rlm_tools_bsl
