# Summary of steps:
# Steps marked with * are conditional
# 1. Stage changes from git
# 2. Run Aras Import
# 3. * Compile dlls
# 4. * Stop application pool
# 5. Copy updated web application files
# 6. * Start application pool

$StartDate = (GET-DATE)
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host -ForegroundColor Green "Update started at: $date"

#$WEB_SERVER = "SE-LT-4452.miclaser.net"
$ARAS_WEB_APPLICATION_POOL_NAME = "Aras Innovator AppPool ASP.NET Core"

# Stage updates
$output = & "$PSScriptRoot\stage_git.ps1"
if ($LASTEXITCODE -gt 0) {
    Write-Host -ForegroundColor Red "Staging Git Failed!"    
    Exit 1
}

# Import
Write-Host "Import staged updates"
$ret = & "$PSScriptRoot\import_update.ps1"

if ($ret -gt 0) {
    Write-Warning "Data model import failed"
    Exit 1
}

# Build and stage server_extensions
& "$PSScriptRoot\build_and_stage_server_extensions.ps1"
if ($LASTEXITCODE -eq 0) {
    Write-Host "No changes to complied code"
}

if ($LASTEXITCODE -gt 1) {
    Write-Host -ForegroundColor Red "Compile and stage failed"
    Exit 1
}

$restartApplicationPool = $false
if ($LASTEXITCODE -eq 1) {
    $restartApplicationPool = $true
    Write-Host -ForegroundColor Green "Compile and stage successful"
}

if ($restartApplicationPool) {
    Write-Host -ForegroundColor Cyan "Stopping application pool"
    Stop-WebAppPool -Name $ARAS_WEB_APPLICATION_POOL_NAME
    $waitTimeOnStoppingApplicationPool = 5
    Write-Host "Waiting $waitTimeOnStoppingApplicationPool seconds on stopping application pool"
    Start-Sleep $waitTimeOnStoppingApplicationPool
    #Invoke-Command -ComputerName $WEB_SERVER -ScriptBlock { Stop-WebAppPool -Name $ARAS_WEB_APPLICATION_POOL_NAME }
    
}

# Deploy Code tree
Write-Host "Deploy Code tree"
$ret = & "$PSScriptRoot\deploy_webapp.ps1"

if ($restartApplicationPool) {
    Write-Host -ForegroundColor Cyan "Starting application pool"  
    $numberOfTries = 10
    $waitTimeBeforeStartingApplicationPool = 2
    for ($i = 0; $i -lt $numberOfTries; $i++) {
        Write-Host "Waiting $waitTimeBeforeStartingApplicationPool seconds before starting application pool"
        Start-Sleep $waitTimeBeforeStartingApplicationPool # Add some delay to avoid error: start-webitem : The service cannot accept control messages at this time.
        # Invoke-Command -ComputerName $WEB_SERVER -ScriptBlock { Start-WebAppPool -Name $ARAS_WEB_APPLICATION_POOL_NAME }
        # Use -erroraction 'silentlycontinue' to prevent execution in gitlab(runner) to abort on error
        # Use try/catch  -erroraction 'silentlycontinue' to prevent execution in gitlab(runner) to abort on error
        try {
            Start-WebAppPool -Name $ARAS_WEB_APPLICATION_POOL_NAME -erroraction 'silentlycontinue'    
        }
        catch {
            <#Do this if a terminating exception happens#>
        }

        $AppPoolState = Get-WebAppPoolState -Name $ARAS_WEB_APPLICATION_POOL_NAME
        if ($AppPoolState.Value -eq "Started") 
        {
            Write-Host -ForegroundColor Green "Application pool is now started"
            break # No need to try anymore
        }
    }       

    # Check application pool status 
    $AppPoolState = Get-WebAppPoolState -Name $ARAS_WEB_APPLICATION_POOL_NAME
    if ($AppPoolState.Value -ne "Started") {
        # Not started!!
        Write-Host -ForegroundColor Red "Application pool is not started"
        Exit 1
    }
}

$EndDate = (GET-DATE)
$TimeSpan = NEW-TIMESPAN -Start $StartDate -End $EndDate
$hr = $TimeSpan.ToString("mm' minutes 'ss' seconds'")
"Execution time: " + $hr
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host -ForegroundColor Green "Update Completed at: $date"