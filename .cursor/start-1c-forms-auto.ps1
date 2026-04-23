# Автозапуск 1c-forms-mcp (Desko77/1c-formsserver) при открытии workspace.
# Порт 8011 — как в .cursor/mcp.json. Если порт занят — выход без дублирования процесса.
$ErrorActionPreference = "Stop"

$FormsMcpPort = 8011

function Test-FormsPortOpen {
	param([int]$Port)
	$client = New-Object System.Net.Sockets.TcpClient
	try {
		$async = $client.BeginConnect("127.0.0.1", $Port, $null, $null)
		if (-not $async.AsyncWaitHandle.WaitOne(400, $false)) {
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

if (Test-FormsPortOpen -Port $FormsMcpPort) {
	exit 0
}

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$runLocal = Join-Path $workspaceRoot "tools\1c-formsserver\run-local.ps1"
if (-not (Test-Path -LiteralPath $runLocal)) {
	exit 1
}

& $runLocal -Port $FormsMcpPort -Background

