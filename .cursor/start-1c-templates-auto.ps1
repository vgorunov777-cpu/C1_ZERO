# Автозапуск MCP шаблонов 1С при открытии рабочей папки (задача VS Code runOn: folderOpen).
# Если порт 8023 уже занят — выход без дублирования процесса.
$ErrorActionPreference = "Stop"

function Test-Port8023Open {
	$client = New-Object System.Net.Sockets.TcpClient
	try {
		$async = $client.BeginConnect("127.0.0.1", 8023, $null, $null)
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

if (Test-Port8023Open) {
	exit 0
}

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$runLocal = Join-Path $workspaceRoot "tools\1c-mcp-templates\run-local.ps1"
if (-not (Test-Path -LiteralPath $runLocal)) {
	exit 1
}

& $runLocal -Background
