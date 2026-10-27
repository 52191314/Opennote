$java = "E:\03_Devops\JDK\bin\java.exe"
$bundletool = "E:\03_Devops\bin\bundletool.jar"
$aab = "E:\02_Projects\Opennote\build\app\outputs\bundle\release\Opennote-release.aab"
$apks = "E:\02_Projects\Opennote\scratch\opennote.apks"
$ks = "E:\02_Projects\Opennote\android\opennote-release.jks"

if (Test-Path $apks) {
    Remove-Item -Force $apks
}

Write-Host "Extracting universal APK from AAB using bundletool..." -ForegroundColor Cyan
& $java -jar $bundletool build-apks `
    --bundle=$aab `
    --output=$apks `
    --mode=universal `
    --ks=$ks `
    --ks-pass=pass:qmLWbh3afhhyXmssQaQKUIz8Q0EujX0f `
    --ks-key-alias=opennote `
    --key-pass=pass:qmLWbh3afhhyXmssQaQKUIz8Q0EujX0f

if ($LASTEXITCODE -ne 0) {
    throw "bundletool build-apks failed with exit code $LASTEXITCODE"
}

Write-Host "Unzipping universal.apk..." -ForegroundColor Green
$universalApkDir = "E:\02_Projects\Opennote\scratch\extracted_apk"
if (Test-Path $universalApkDir) {
    Remove-Item -Recurse -Force $universalApkDir
}
Expand-Archive -Path $apks -DestinationPath $universalApkDir -Force
$apk = Join-Path $universalApkDir "universal.apk"
Write-Host "Universal APK ready at: $apk ($([math]::Round((Get-Item $apk).Length / 1MB, 2)) MB)" -ForegroundColor Green
