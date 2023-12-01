param (
    [Parameter(Mandatory=$true)][string]$env
 )

 $STAGE_DIR = "$PSScriptRoot\stage\"

 Write-Host "Creating package for '$env'"

 $envConfigFile = ".\env\env.$env.config"

 if(-NOT (Test-Path $envConfigFile)) {
    Write-Warning "Path $envCofigFile does not exist"
    return 1
 }

# Stage changes with git
.\stage_git.ps1 --local

# Write Package Notes (who, when, commit hash, branch, from-to-date)
$packageNotesFile = $STAGE_DIR + "PackageInfo.txt"	

$userName = $Env:UserName
Add-Content -Path $packageNotesFile -Value "Created By: $userName"

$packDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $packageNotesFile -Value "At: $packDate"

Add-Content -Path $packageNotesFile -Value "Target Environment: $env"

$version = Get-Content "..\..\version.txt" -First 1
Add-Content -Path $packageNotesFile -Value "Version: $version"

$commitHash = git rev-parse HEAD
$commitHash = $commitHash.substring(0,8)
Add-Content -Path $packageNotesFile -Value "At commit: $commitHash"

$branch = git rev-parse --abbrev-ref HEAD
Add-Content -Path $packageNotesFile -Value "On branch: $branch"

$fromDate = (Get-Content "$PSScriptRoot\stage_from_date.txt")[0]
$toDate = git show --no-patch --format=%ci $commitHash
Add-Content -Path $packageNotesFile -Value "Contains changes from: $fromDate to: $toDate"

# Copy env config to stage
Copy-Item -Path $envConfigFile -Destination "$STAGE_DIR\env.config"

# Copy version file to stage
Copy-Item -Path "..\..\version.txt" -Destination $STAGE_DIR

# Copy update script to stage
Copy-Item -Path ".\update_package.ps1" -Destination $STAGE_DIR

# Rename stage dir
#Clean stage sub dirs
$DEPLOY_DIR_NAME = "DeployPackage_$version"+"_$commitHash"
if(Test-Path $DEPLOY_DIR_NAME) {
	"Removing dir: " + $DEPLOY_DIR_NAME
	Remove-Item -Recurse -Force $DEPLOY_DIR_NAME
}
Rename-Item -Path $STAGE_DIR -NewName $DEPLOY_DIR_NAME

# Zip stage dir
$zipFileName = "DeployPackage_$version"+"_$commitHash.zip"
if(Test-Path $zipFileName) {
	Remove-Item -Force $zipFileName
}
Write-Host -ForegroundColor Green "Zipping file to : $zipFileName"
Compress-Archive -Path ".\$DEPLOY_DIR_NAME\" -DestinationPath ".\$zipFileName"
explorer.exe .\
