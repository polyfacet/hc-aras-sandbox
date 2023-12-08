param (
    [Parameter(Mandatory=$false)][string]$env
 )

$environment = .\readConfig.ps1 $env
$database = $environment.Database
$backupDir = $environment.DBBackupPath

$time = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
$backupFileName = $database + "_" + $time + ".bak"
$backupFilePath = Join-Path -Path $backupDir -ChildPath $backupFileName

Write-Host -ForegroundColor Cyan -BackgroundColor Black "Creating backup file of db = '$database' to file path: '$backupFilePath'"
SQLCMD.EXE -S .\ -E -Q "BACKUP DATABASE $database TO DISK = '$backupFilePath' WITH FORMAT"