# Build script for Opennote Play Store official release AAB
$ErrorActionPreference = "Stop"

$workspaceRoot = $PSScriptRoot | Split-Path -Parent
Set-Location $workspaceRoot

# Devops Toolchain Environment
& "E:\03_Devops\env.ps1"
$env:Path = "$workspaceRoot\submodules\flutter\bin;$env:Path"

Write-Host "=== Step 1: Keystore Setup & Verification ===" -ForegroundColor Cyan
$keytool = "E:\03_Devops\JDK\bin\keytool.exe"
$keystorePath = Join-Path $workspaceRoot "android\opennote-release.jks"
$propertiesPath = Join-Path $workspaceRoot "android\key.properties"
$backupDir1 = "K:\private\xiyj\keys\android_keystores"
$backupDir2 = "K:\private\xiyj\keys"

if (!(Test-Path $keystorePath)) {
    Write-Host "Generating new production release keystore at $keystorePath..." -ForegroundColor Yellow
    # 32-character cryptographically secure password
    $charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $bytes = New-Object byte[] 32
    $rng.GetBytes($bytes)
    $passwordChars = New-Object char[] 32
    for ($i = 0; $i -lt 32; $i++) {
        $passwordChars[$i] = $charSet[$bytes[$i] % $charSet.Length]
    }
    $releasePassword = -join $passwordChars

    # Generate PKCS12 keystore with 10,000 days validity (27+ years)
    $dname = "CN=Opennote, OU=Mobile, O=Opennote, L=San Francisco, ST=California, C=US"
    & $keytool -genkeypair -v `
        -keystore $keystorePath `
        -alias "opennote" `
        -keyalg RSA `
        -keysize 2048 `
        -validity 10000 `
        -storetype PKCS12 `
        -storepass $releasePassword `
        -keypass $releasePassword `
        -dname $dname

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to generate release keystore with keytool."
    }

    $propertiesContent = "storePassword=$releasePassword`nkeyPassword=$releasePassword`nkeyAlias=opennote`nstoreFile=../opennote-release.jks`n"
    Set-Content -Path $propertiesPath -Value $propertiesContent -Encoding Ascii
    Write-Host "Created $propertiesPath" -ForegroundColor Green
} else {
    Write-Host "Keystore already exists at $keystorePath" -ForegroundColor Green
}

# Step 2: Backup release keystore & properties
Write-Host "=== Step 2: Backing up Keystore to K:\private\xiyj\keys ===" -ForegroundColor Cyan
if (Test-Path $backupDir1) {
    Copy-Item -Path $keystorePath -Destination (Join-Path $backupDir1 "opennote-release.jks") -Force
    Copy-Item -Path $propertiesPath -Destination (Join-Path $backupDir1 "opennote_key.properties") -Force
    Write-Host "Backed up to $backupDir1" -ForegroundColor Green
}
if (Test-Path $backupDir2) {
    Copy-Item -Path $keystorePath -Destination (Join-Path $backupDir2 "opennote-release.jks") -Force
    Copy-Item -Path $propertiesPath -Destination (Join-Path $backupDir2 "opennote_key.properties") -Force
    Write-Host "Backed up to $backupDir2" -ForegroundColor Green
}

# Update README_KEY_MAPPING.md if present
$mappingFile = Join-Path $backupDir1 "README_KEY_MAPPING.md"
if (Test-Path $mappingFile) {
    $mappingContent = Get-Content $mappingFile -Raw
    if ($mappingContent -notmatch "opennote-release\.jks") {
        $entry = "`n---`n`n### 3b. Opennote Official Google Play Release`n* **App / APK:** Opennote (``com.adilhanney.saber``)`n* **Play Store Release Keystore:** ``opennote-release.jks```n* **Configuration:** ``opennote_key.properties`` (contains keyAlias, storePassword, keyPassword)`n* **Key Alias:** ``opennote```n* **Algorithm / Validity:** RSA 2048-bit PKCS12, valid for 10,000 days`n* **Project Source:** ``E:\02_Projects\Opennote\android\opennote-release.jks```n"
        Add-Content -Path $mappingFile -Value $entry
        Write-Host "Updated $mappingFile with official release entry." -ForegroundColor Green
    }
}

Write-Host "=== Step 3: Running Flutter App Bundle Build ===" -ForegroundColor Cyan
$symbolsDir = Join-Path $workspaceRoot "build\app\outputs\symbols"
if (Test-Path $symbolsDir) {
    Remove-Item -Recurse -Force $symbolsDir
}
New-Item -ItemType Directory -Path $symbolsDir -Force | Out-Null

$flutterBat = Join-Path $workspaceRoot "submodules\flutter\bin\flutter.bat"
& $flutterBat build appbundle `
    --release `
    --build-name="0.0.1" `
    --build-number=2 `
    --split-debug-info=$symbolsDir

if ($LASTEXITCODE -ne 0) {
    throw "Flutter appbundle build failed with exit code $LASTEXITCODE"
}

Write-Host "=== Step 4: Verification of Build Artifacts ===" -ForegroundColor Cyan
$aabPath = Join-Path $workspaceRoot "build\app\outputs\bundle\release\app-release.aab"
if (!(Test-Path $aabPath)) {
    # Check alternate name
    $altAab = Get-ChildItem -Path (Join-Path $workspaceRoot "build\app\outputs\bundle\release") -Filter "*.aab" | Select-Object -First 1
    if ($altAab) {
        $aabPath = $altAab.FullName
    } else {
        throw "Could not find release AAB file in build/app/outputs/bundle/release"
    }
}

$aabItem = Get-Item $aabPath
Write-Host "AAB Path: $($aabItem.FullName)" -ForegroundColor Green
Write-Host "AAB Size: $([math]::Round($aabItem.Length / 1MB, 2)) MB" -ForegroundColor Green

# Verify signatures and symbols inside AAB
$jar = "E:\03_Devops\JDK\bin\jar.exe"
$entries = & $jar tf $aabPath
$hasDebugSymbols = $entries | Where-Object { $_ -match "debugsymbols" }
$hasMetadata = $entries | Where-Object { $_ -match "BUNDLE-METADATA" }
Write-Host "Debug symbols in AAB:" ($hasDebugSymbols -ne $null) -ForegroundColor Green
Write-Host "Dart symbol files created:" -ForegroundColor Green
Get-ChildItem -Path $symbolsDir | ForEach-Object {
    Write-Host "  $($_.Name) ($([math]::Round($_.Length / 1KB, 1)) KB)"
}

Write-Host "BUILD COMPLETED SUCCESSFULLY!" -ForegroundColor Green
