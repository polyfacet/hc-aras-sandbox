param (
    [Parameter(Mandatory=$false)][string]$env
 )

if ([string]::IsNullOrEmpty($env) ) {
    $env = 'dev'
}

 Write-Host "Updating environment: $env"

$envProps = & "$PSScriptRoot\util-scripts\readConfig.ps1" $env

Write-Host "Setting environment variables for deployment"
$env:SERVER = $envProps.ArasConnection.Url 
$env:DB = $envProps.ArasConnection.Db
$env:ADMIN_USER = $envProps.ArasConnection.User
$env:ADMIN_PASSWORD = $envProps.ArasConnection.Password
$env:WEB_APP_PATH = $envProps.WebAppPath 
$env:CONSOLE_UPGRADE_PATH = $envProps.Import.ConsoleUpgradePath

Write-Host -ForegroundColor Cyan "SERVER: $env:SERVER"
Write-Host -ForegroundColor Cyan "DB: $env:DB"
Write-Host -ForegroundColor Cyan "WEB_APP_PATH: $env:WEB_APP_PATH"

& "$PSScriptRoot\deploy\update_deploy.ps1"
