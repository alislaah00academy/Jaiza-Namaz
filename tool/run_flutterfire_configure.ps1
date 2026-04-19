# Run FlutterFire CLI without adding Pub global bin to system PATH.
# Usage (from any directory):
#   powershell -ExecutionPolicy Bypass -File "E:\jaiza_namaz\tool\run_flutterfire_configure.ps1"
# Optional: pass extra args, e.g. --yes
#   powershell -ExecutionPolicy Bypass -File "...\run_flutterfire_configure.ps1" -- --yes

$ErrorActionPreference = "Stop"
$pubBin = Join-Path $env:LOCALAPPDATA "Pub\Cache\bin"
if (-not (Test-Path (Join-Path $pubBin "flutterfire.bat"))) {
    Write-Host "flutterfire not found. Run: dart pub global activate flutterfire_cli" -ForegroundColor Yellow
    exit 1
}
$env:Path = "$pubBin;$env:Path"

# Script lives in <project>/tool/ — project root is one level up
$root = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path (Join-Path $root "pubspec.yaml"))) {
    Write-Host "pubspec.yaml not found above tool folder. Run this script from the repo as shipped." -ForegroundColor Red
    exit 1
}
Set-Location $root
Write-Host "Project root: $root" -ForegroundColor Cyan

$extra = @()
if ($args.Count -gt 0) { $extra = $args }

& flutterfire configure --project=jaiza-namaz @extra
