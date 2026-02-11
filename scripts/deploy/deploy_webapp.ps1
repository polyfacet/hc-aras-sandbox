$STAGE_DIR = "$PSScriptRoot\stage\"
$ArasWebAppPath = $env:WEB_APP_PATH

Write-Host -ForegroundColor Green "Copy staged files to: $ArasWebAppPath"  
$folder = "$STAGE_DIR\webapp\Client"
New-Item -ItemType Directory -Force -Path $folder | Out-Null 
Copy-Item -Path $folder -Destination $ArasWebAppPath -Recurse -Force
$folder = "$STAGE_DIR\webapp\Server"
if (Test-Path -Path $folder) {
	Write-Host "Copy new server files"
    # $ret = & "$PSScriptRoot\..\util-scripts\restart-aras-app-pool.ps1"
	New-Item -ItemType Directory -Force -Path $folder | Out-Null 
	Copy-Item -Path $folder -Destination $ArasWebAppPath -Recurse -Force
}