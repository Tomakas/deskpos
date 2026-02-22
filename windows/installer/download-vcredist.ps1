# Downloads the latest VC++ Redistributable (x64) for bundling with the installer.
# Run this in CI before building the Inno Setup installer.

$OutDir = "$PSScriptRoot\vcredist"
$OutFile = "$OutDir\vc_redist.x64.exe"

if (Test-Path $OutFile) {
    Write-Host "vc_redist.x64.exe already exists, skipping download."
    exit 0
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$Url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
Write-Host "Downloading VC++ Redistributable from $Url ..."
Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing

if (Test-Path $OutFile) {
    Write-Host "Downloaded successfully: $OutFile"
} else {
    Write-Error "Download failed!"
    exit 1
}
