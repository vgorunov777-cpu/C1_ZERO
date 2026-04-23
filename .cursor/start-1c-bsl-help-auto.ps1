# OPTIONAL: SSE server on :8080 (web UI / http://localhost:8080/sse). Not used by default MCP (stdio via run-bsl-mcp.cmd).
# JAR: alkoleft/mcp-bsl-platform-context. Platform path: ONEC_BSL_HELP_PLATFORM_PATH or latest under Program Files\1cv8.
$ErrorActionPreference = "Stop"

$JarVersion = "0.3.2"
$JarName = "mcp-bsl-context-$JarVersion.jar"
$ReleaseJarUrl = "https://github.com/alkoleft/mcp-bsl-platform-context/releases/download/v$JarVersion/$JarName"

function Test-Port8080Open {
	$client = New-Object System.Net.Sockets.TcpClient
	try {
		$async = $client.BeginConnect("127.0.0.1", 8080, $null, $null)
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

function Get-1CPlatformDirectory {
	if ($env:ONEC_BSL_HELP_PLATFORM_PATH) {
		$p = $env:ONEC_BSL_HELP_PLATFORM_PATH.TrimEnd('\', '/')
		if ((Test-Path -LiteralPath $p) -and (Test-Path -LiteralPath (Join-Path $p "bin"))) {
			return $p
		}
	}
	$roots = @(
		"C:\Program Files\1cv8",
		"C:\Program Files (x86)\1cv8"
	)
	foreach ($root in $roots) {
		if (-not (Test-Path -LiteralPath $root)) {
			continue
		}
		$candidates = @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue | Where-Object {
				(Test-Path -LiteralPath (Join-Path $_.FullName "bin"))
			})
		if ($candidates.Count -eq 0) {
			continue
		}
		$sorted = $candidates | Sort-Object {
				try {
					[System.Version]::Parse($_.Name)
				}
				catch {
					[System.Version]::Parse("0.0.0.0")
				}
			} -Descending
		return $sorted[0].FullName
	}
	return $null
}

if (Test-Port8080Open) {
	exit 0
}

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$jarDir = Join-Path $workspaceRoot "tools\1c-bsl-help"
$jarPath = Join-Path $jarDir $JarName

if (-not (Test-Path -LiteralPath $jarPath)) {
	New-Item -ItemType Directory -Path $jarDir -Force | Out-Null
	Write-Host "Downloading $JarName ..." -ForegroundColor Cyan
	Invoke-WebRequest -Uri $ReleaseJarUrl -OutFile $jarPath -UseBasicParsing
}

$java = (Get-Command java -ErrorAction SilentlyContinue).Source
if (-not $java) {
	Write-Error "Java not found in PATH (need 17+)."
	exit 1
}

$platformPath = Get-1CPlatformDirectory
if (-not $platformPath) {
	Write-Error "1C platform directory not found. Install 1C:Enterprise or set env ONEC_BSL_HELP_PLATFORM_PATH to folder that contains bin (e.g. C:\Program Files\1cv8\8.3.27.1606)."
	exit 1
}

$argLine = @(
	"-Dfile.encoding=UTF-8",
	"-jar",
	"`"$jarPath`"",
	"--mode", "sse",
	"--port", "8080",
	"--platform-path",
	"`"$platformPath`""
) -join " "

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $java
$psi.Arguments = $argLine
$psi.WorkingDirectory = $jarDir
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true

[void][System.Diagnostics.Process]::Start($psi)
exit 0
