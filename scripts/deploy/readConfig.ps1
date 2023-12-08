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
return $environment