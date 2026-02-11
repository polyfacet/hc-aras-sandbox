Write-Host -ForegroundColor Cyan "Starting import"

# Load properties from GITLAB
$server = $env:SERVER
$db = $env:DB
$login = $env:ADMIN_USER
$password = $env:ADMIN_PASSWORD
$importProg = $env:CONSOLE_UPGRADE_PATH
$manifestFilePath = $env:MANIFEST_FILE_PATH # We don't need this variable, instead we could have an optional $manifestFileName


Write-Host "`t Manifest file path: $manifestFilePath"
$STAGE_DIR = "$PSScriptRoot\stage"
$manifestFileName = "myupdate.mf" 
$manifestFilePath = "$STAGE_DIR\packages\MYAras\$manifestFileName"

# Convert relative path to full path
$rel = ".\"
if ($manifestFilePath.StartsWith($rel)) {
	#Write-Host "Replace relative path .\"
	$manifestFilePath = $manifestFilePath -replace ([regex]::Escape("$rel")), "$pwd\"
}

$importDir = Split-Path -Path $manifestFilePath

$release = Get-Content "$PSScriptRoot\..\..\version.txt" -First 1

Write-Host "Configuration for: $env"
Write-Host "`t Server: $server"
Write-Host "`t DB: $db"
Write-Host "`t Login: $login"
Write-Host "`t Import app path: $importProg"
Write-Host "`t Import dir path: $importDir"
Write-Host "`t Manifest file path: $manifestFilePath"
Write-Host "`t Release: $release"

if(Test-Path $manifestFilePath) {
	
	# Set parameters
	$params = "server=" + $server + " database=" + $db + " login=" + $login + " password=" + $password + " dir=" + """$importDir"""  + " mfFile=" + """$manifestFilePath""" + " release=" + $release + " import merge"
	#$params

	Write-Host -ForegroundColor Cyan "Start Import"
	# Execute Import script
	$ret2 = Start-Process -FilePath $importProg $params -Wait -NoNewWindow -PassThru
	
	if ($ret2.ExitCode -ne 0) {
		Write-Error "Import failed"
		return $ret2.ExitCode
	} else {
		Write-Host -ForegroundColor Green "Import successful: $manifestFilePath"
		return 0
	}
} else {
	Write-Host -ForegroundColor Yellow "Nothing to import: $importDir"
	return 0
}
