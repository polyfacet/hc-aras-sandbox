# Exit with 0, if nothing needs to be re-compiled
# Exit with 1, if compile is needed and is successful
# Exit with 2, if compile is needed and fails
# NOTE: This script depends on that staged git changes has been done to $STAGE_DIR, to evaluate if a "build" is needed or not

$STAGE_DIR = "$PSScriptRoot\stage\"
$SERVER_EXTENSION_FOLDERS = @('AcmeArasBusiness','AcmeArasCore')
# NOTE: The array is ordered. So if Business is changed, it will include M3 and Core to, as those are dependencies
# Hence, we exit after first compilation.


Write-Host "Checking if change requires compilation"

foreach ( $node in $SERVER_EXTENSION_FOLDERS )
{
    $compiledCodeDir = $node    
    $folder = "$STAGE_DIR\server_extensions\$compiledCodeDir"
    if (Test-Path -Path $folder) {
        Write-Host "Changes in $folder, run compile"
        & "$PSScriptRoot\build-server-extensions.ps1"
        if ($LASTEXITCODE -gt 0) {
            Exit 2
        }
        Exit 1
    }    
}
Exit 0