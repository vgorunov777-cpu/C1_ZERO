@echo off
setlocal EnableExtensions
set "HERE=%~dp0"
set "REL=%HERE%..\..\"
pushd "%REL%" || exit /b 1
set "ROOT=%CD%"
popd || exit /b 1

set "JAR=%ROOT%\tools\1c-bsl-help\mcp-bsl-context-0.3.2.jar"
set "PPFILE=%ROOT%\.cursor\bsl-help-platform-path.txt"

if not exist "%JAR%" (
  echo [1c-bsl-help] JAR not found: %JAR% 1>&2
  exit /b 1
)
if not exist "%PPFILE%" (
  echo [1c-bsl-help] Create platform path file: powershell -File "%ROOT%\tools\1c-bsl-help\configure-platform.ps1" 1>&2
  exit /b 1
)
set /p PP=<"%PPFILE%"
if "%PP%"=="" (
  echo [1c-bsl-help] Empty %PPFILE% 1>&2
  exit /b 1
)

where java >nul 2>&1
if errorlevel 1 (
  echo [1c-bsl-help] Java not in PATH 1>&2
  exit /b 1
)

java -Dfile.encoding=UTF-8 -jar "%JAR%" --platform-path "%PP%"
exit /b %ERRORLEVEL%
