# Script to build release APK for Opennote with full DevOps environment
$ErrorActionPreference = "Stop"

$workspaceRoot = "E:\02_Projects\Opennote"
Set-Location $workspaceRoot

# Source MSVC and toolchains
& "E:\03_Devops\env.ps1"

# Prepend Opennote pinned Flutter submodule
$env:Path = "$workspaceRoot\submodules\flutter\bin;$env:Path"

Write-Host "Building release APK..." -ForegroundColor Cyan
$flutterBat = Join-Path $workspaceRoot "submodules\flutter\bin\flutter.bat"

& $flutterBat build apk --release --build-name="0.0.1" --build-number=2

if ($LASTEXITCODE -ne 0) {
    throw "Flutter build apk failed with code $LASTEXITCODE"
}

Write-Host "APK Build successful!" -ForegroundColor Green
Get-ChildItem -Recurse -Filter "*.apk" build\app\outputs\flutter-apk
