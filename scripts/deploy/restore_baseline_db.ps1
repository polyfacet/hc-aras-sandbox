param (
    [Parameter(Mandatory=$true)][string]$env
 )

 Write-Host -ForegroundColor Green "Restoring environment: $env" 
 
#Read properties
$envProps = .\readConfig.ps1 $env
$database_name = $envProps.Database
$sqlCommand = "sqlcmd"
$base_line_backup_file_path = $envProps.DBBaselineBackupPath

Write-Host -ForegroundColor Cyan "Kill processes for $database_name"
$query = "USE master;
GO
ALTER DATABASE $database_name  
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
ALTER DATABASE $database_name
SET MULTI_USER;
GO"

$params = " -S .\ -E -Q " + " ""  " + $query + " "" "
Start-Process -FilePath $sqlCommand $params -Wait -NoNewWindow -PassThru

Write-Host -ForegroundColor Cyan "Restore Database: $database_name"
$query = "RESTORE DATABASE " + $database_name + " FROM DISK='" + $base_line_backup_file_path + "'  WITH REPLACE"
$params = " -S .\ -E -Q " + " ""  " + $query + " "" "
Start-Process -FilePath $sqlCommand $params -Wait -NoNewWindow -PassThru

Write-Host -ForegroundColor Cyan "Alter innovator user - required for imports from another database manager"
$query = "ALTER USER INNOVATOR WITH LOGIN=INNOVATOR
ALTER USER INNOVATOR_REGULAR WITH LOGIN=INNOVATOR_REGULAR"
$params = " -S .\ -d " + $database_name + " -E -Q " + " ""  " + $query + " "" "

Start-Process -FilePath $sqlCommand $params -Wait -NoNewWindow -PassThru

#Restart application pool to avoid issues with cached information in (Aras) application 
..\util-scripts\restart-aras-app-pool.ps1
