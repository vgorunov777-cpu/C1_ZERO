# xlsx-to-mxl v2.0 — Convert XLSX to Template.xml or MXL via 1C MCP HTTP service
<#
.SYNOPSIS
    Конвертация XLSX в Template.xml или MXL через HTTP-сервис MCP 1С

.DESCRIPTION
    Отправляет XLSX в формате base64 на HTTP-сервис 1С (MCP convert_file),
    получает результат (XML или MXL) в base64 и записывает рядом с исходным файлом.
    Не запускает 1С — работает через уже запущенный HTTP-сервис.

.PARAMETER XlsxPath
    Путь к исходному XLSX-файлу

.PARAMETER OutputPath
    Куда положить результат (по умолчанию — рядом с XLSX)

.PARAMETER Format
    Целевой формат: xml (по умолчанию) или mxl

.PARAMETER McpUrl
    URL MCP-сервиса (по умолчанию http://server-1c:3080/work/hs/mcp/)

.PARAMETER Key
    Ключ доступа к MCP-сервису
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$XlsxPath,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath,

    [Parameter(Mandatory=$false)]
    [ValidateSet("xml", "mxl")]
    [string]$Format = "xml",

    [Parameter(Mandatory=$false)]
    [string]$McpUrl = "http://server-1c:3080/work/hs/mcp/",

    [Parameter(Mandatory=$false)]
    [string]$Key = ""
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Validate input ---
if (-not (Test-Path $XlsxPath)) {
    Write-Host "Error: file not found: $XlsxPath" -ForegroundColor Red
    exit 1
}

$XlsxPath = (Resolve-Path $XlsxPath).Path
$xlsxDir = Split-Path $XlsxPath -Parent
$xlsxName = [System.IO.Path]::GetFileNameWithoutExtension($XlsxPath)

# --- Default output path ---
if (-not $OutputPath) {
    if ($Format -eq "xml") {
        $OutputPath = Join-Path $xlsxDir "Template.xml"
    } else {
        $OutputPath = Join-Path $xlsxDir "$xlsxName.mxl"
    }
}

# --- Read and encode file ---
Write-Host "Reading: $XlsxPath"
$fileBytes = [System.IO.File]::ReadAllBytes($XlsxPath)
$base64Data = [System.Convert]::ToBase64String($fileBytes)
$fileSizeKB = [math]::Round($fileBytes.Length / 1024, 1)
Write-Host "File size: ${fileSizeKB} KB, base64 length: $($base64Data.Length) chars"

# --- Build JSON-RPC request ---
$requestBody = @{
    jsonrpc = "2.0"
    id = 1
    method = "tools/call"
    params = @{
        name = "convert_file"
        arguments = @{
            Data = $base64Data
            Format = $Format
            Key = $Key
        }
    }
} | ConvertTo-Json -Depth 5 -Compress

$requestSizeKB = [math]::Round([System.Text.Encoding]::UTF8.GetByteCount($requestBody) / 1024, 1)
Write-Host "Sending ${requestSizeKB} KB to $McpUrl ..."

# --- Send request ---
try {
    $response = Invoke-RestMethod -Uri $McpUrl -Method Post -Body $requestBody -ContentType "application/json; charset=utf-8" -TimeoutSec 120
} catch {
    Write-Host "Error: HTTP request failed: $_" -ForegroundColor Red
    exit 1
}

# --- Parse response ---
# Response format: { "jsonrpc": "2.0", "id": 1, "result": { "content": [{ "type": "text", "text": "base64..." }], "isError": false } }
if ($response.error) {
    Write-Host "Error from 1C: $($response.error.message)" -ForegroundColor Red
    exit 1
}

$result = $response.result
if ($result.isError -eq $true) {
    $errorText = ($result.content | ForEach-Object { $_.text }) -join "`n"
    Write-Host "Error from 1C: $errorText" -ForegroundColor Red
    exit 1
}

$resultBase64 = ($result.content | Where-Object { $_.type -eq "text" } | Select-Object -First 1).text

if (-not $resultBase64) {
    Write-Host "Error: empty response from 1C" -ForegroundColor Red
    exit 1
}

# --- Check for error messages in response (not base64) ---
if ($resultBase64.StartsWith("Ошибка") -or $resultBase64.StartsWith("Error")) {
    Write-Host "Error from 1C: $resultBase64" -ForegroundColor Red
    exit 1
}

# --- Decode and write result ---
try {
    $resultBytes = [System.Convert]::FromBase64String($resultBase64)
} catch {
    Write-Host "Error: failed to decode base64 response: $_" -ForegroundColor Red
    Write-Host "Response preview: $($resultBase64.Substring(0, [math]::Min(200, $resultBase64.Length)))" -ForegroundColor Yellow
    exit 1
}

$outDir = Split-Path $OutputPath -Parent
if ($outDir -and -not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

[System.IO.File]::WriteAllBytes($OutputPath, $resultBytes)
$resultSizeKB = [math]::Round($resultBytes.Length / 1024, 1)
Write-Host "OK: $OutputPath (${resultSizeKB} KB)" -ForegroundColor Green

exit 0
