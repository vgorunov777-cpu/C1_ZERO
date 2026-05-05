# Writes .cursor/bsl-help-platform-path.txt (one line) for run-bsl-mcp.cmd / MCP stdio.
# Uses ONEC_BSL_HELP_PLATFORM_PATH or latest 1cv8 version folder that contains bin.
$ErrorActionPreference = "Stop"

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

$scriptDir = $PSScriptRoot
$workspaceRoot = Split-Path (Split-Path $scriptDir -Parent) -Parent
$outFile = Join-Path $workspaceRoot ".cursor\bsl-help-platform-path.txt"

$platform = Get-1CPlatformDirectory
if (-not $platform) {
	Write-Error "1C platform not found. Set ONEC_BSL_HELP_PLATFORM_PATH to folder containing bin (e.g. C:\Program Files\1cv8\8.3.27.1606)."
	exit 1
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outFile, $platform, $utf8NoBom)
Write-Host "Written: $outFile" -ForegroundColor Green
Write-Host "  $platform" -ForegroundColor Gray
exit 0
