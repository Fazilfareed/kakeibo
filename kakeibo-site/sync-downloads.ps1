# Copies the release APKs from ../kakeibo-app-build into downloads/ before publishing.
$src = Join-Path $PSScriptRoot "..\kakeibo-app-build"
$dst = Join-Path $PSScriptRoot "downloads"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
foreach ($name in @("kakeibo-1.0.0-arm64-v8a.apk", "kakeibo-1.0.0-armeabi-v7a.apk")) {
    Copy-Item -Path (Join-Path $src $name) -Destination $dst -Force
    Write-Host "copied $name"
}
