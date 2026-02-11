$TEMP_DIR = "$PSScriptRoot\stage\temp-compile"
$TARGET_DIR = "$PSScriptRoot\stage\webapp\Server\bin"

#Clean temp dir
if(Test-Path $TEMP_DIR) {
	"Removing temp dir: " + $TEMP_DIR
	Remove-Item -Recurse -Force $TEMP_DIR
}

# UGLY: The $compiledCodeDir is from build_and_stage_server_extensions.ps1, struggle to get parameters working from there to here...
if ($compiledCodeDir -eq "AcmeArasBusiness") {
    dotnet build -c Release --force --use-current-runtime --os win --property WarningLevel=0 -o $TEMP_DIR $PSScriptRoot\..\..\server_extensions\$compiledCodeDir\$compiledCodeDir.vbproj
}
else {
    dotnet build -c Release --force --use-current-runtime --os win --property WarningLevel=0 -o $TEMP_DIR $PSScriptRoot\..\..\server_extensions\$compiledCodeDir\$compiledCodeDir\$compiledCodeDir.vbproj
}

if ($LASTEXITCODE -gt 0) {
    Write-Error "Build failed"
    Exit 1
}

Write-Host -ForegroundColor Cyan "Cleaning build of Acme dlls in: $TEMP_DIR"

Get-ChildItem $TEMP_DIR | 
Foreach-Object {
    $delete = $true
    if ($_.Name.StartsWith("Acme.Aras")) {
        # echo $_.Name
        if ($_.Name.EndsWith((".dll"))) {
            $delete = $false
        }
        if ($_.Name.EndsWith((".pdb"))) {
            $delete = $false
        }
    }
    if ($delete) {
        # Write-Host -ForegroundColor Red $_.Name
        Remove-Item $_.FullName
    }
    else {
        Write-Host -ForegroundColor Green $_.Name
    }
}

Write-Host -ForegroundColor Cyan "Copy to target: $TARGET_DIR"
Copy-Item -Recurse -Path $TEMP_DIR -Destination $TARGET_DIR
