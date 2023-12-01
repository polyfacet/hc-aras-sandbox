param (
    [Parameter(Mandatory=$false)][string]$env
 )

if ([string]::IsNullOrEmpty($env) ) {
	$arasEnvConfigFile = ".\env.config"
}
else {
	$arasEnvConfigFile = ".\env\env.$env.config"
}

if(-Not (Test-Path $arasEnvConfigFile)) {
	Write-Error "$arasEnvConfigFile does not exist"
	exit 1
}

$xmldoc = [xml] (Get-Content $arasEnvConfigFile)
$environment = $xmldoc.SelectNodes("//Env").Item(0)
$server = $environment.Server
$db = $environment.Database
$login = $environment.Login
$webappPath = $environment.WebappPath
$consoleUpgradePath = $environment.ConsoleUpgradePath

Write-Host -ForegroundColor Green -BackgroundColor Black "Server: $server"
Write-Host -ForegroundColor Green -BackgroundColor Black "Database: $db"
Write-Host "As: $login, Appliction Path: $webappPath"
Write-Host "Console Upgrade Path: $consoleUpgradePath"
Write-Host "Are you Sure You Want To Proceed with the update updating:" -ForegroundColor yellow
$confirmation = $(Write-Host "Enter (y) for yes" -ForegroundColor yellow; Read-Host)
if (-Not ($confirmation -eq 'y')) {
    Write-Host "Aborted"
    return 1
}

$StartDate = (GET-DATE)
	
# Import via console upgrade
$manifestFilePath = ".\packages\update.mf"
$importDir = Split-Path -Path $manifestFilePath
$release =Get-Content ".\version.txt" -First 1
$password = Read-Host "Enter Password for $login" -MaskInput

if(Test-Path $manifestFilePath) {
	# Set parameters
	$params = "server=" + $server + " database=" + $db + " login=" + $login + " password=" + $password + " dir=" + """$importDir"""  + " mfFile=" + """$manifestFilePath""" + " release=" + $release + " import merge"
    $ret2 = Start-Process -FilePath $consoleUpgradePath $params -Wait -NoNewWindow -PassThru
    if ($ret2.ExitCode -gt 0) {
		Write-Warning "Import failed"
		return $ret2.ExitCode
	} else {
		Write-Host -ForegroundColor Green "Import successful: $manifestFilePath"
	}
}

# Deploy webapp
Write-Host -ForegroundColor Cyan "Deploy webapp changes"
$folder = ".\webapp\Client"
New-Item -ItemType Directory -Force -Path $folder | Out-Null 
Copy-Item -Path $folder -Destination $webappPath -Recurse -Force
$folder = ".\webapp\Server"
New-Item -ItemType Directory -Force -Path $folder | Out-Null 
Copy-Item -Path $folder -Destination $webappPath -Recurse -Force
 

$EndDate = (GET-DATE)
$TimeSpan = NEW-TIMESPAN -Start $StartDate -End $EndDate
$hr = $TimeSpan.ToString("mm' minutes 'ss' seconds'")
"Execution time: " + $hr
$end = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host -ForegroundColor Green "Update Completed at: $end"