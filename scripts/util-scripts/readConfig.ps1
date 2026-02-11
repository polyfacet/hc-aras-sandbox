param (
    [Parameter(Mandatory=$false)][string]$env
 )

$arasEnvConfigFile = "$PSScriptRoot\..\aras-env.config"
$xmldoc = [xml] (Get-Content $arasEnvConfigFile)
$environments = $xmldoc.SelectNodes("//Environment")

foreach ($item in $environments) {
    if ($item.Name -eq $env) {
        return $item
    }
    $item.ArasConnection.Url
    $item.ArasConnection.Db
    $item.ArasConnection.User
    $item.ArasConnection.Password
    #$name = $a.SelectSingleNode("/Name")
   
}
