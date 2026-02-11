$STAGE_DIR = "$PSScriptRoot\stage\"
$ROOT_DIR = "$PSScriptRoot\..\.."
$FROM_DATE = Get-Content $PSScriptRoot\stage_from_date.txt -First 1

Write-Host -ForegroundColor Cyan "Staging git changes for: '$env'"

Write-Host -ForegroundColor Cyan "Running deploy from branch $env:CI_COMMIT_BRANCH"
Write-Host -ForegroundColor Cyan "Staging with git from: " $FROM_DATE
git log --name-status --pretty="" --after=$FROM_DATE  > stage.log

#Clean stage sub dirs
if(Test-Path $STAGE_DIR) {
	"Removing stage dir: " + $STAGE_DIR
	Remove-Item -Recurse -Force $STAGE_DIR
}

$content = Get-Content stage.log 
"Files to copy:"
$fileCount = 0
foreach ($line in $content)
{
    #Write-Host $line
	$action, $filePath = $line.split('	')
	
	$addedFile = $action -Match "A"
	$modfiedFile = $action -Match "M"
	if ($addedFile -OR $modfiedFile) {
		$fileToAdd = $filePath
		#Write-Host -ForegroundColor Green $fileToAdd
		$fileToAdd
		
		$folder = Split-Path -parent $fileToAdd
		$folder = $STAGE_DIR + $folder
		
		$fileToAdd = "$ROOT_DIR\$fileToAdd"
		# Create folder, silent output
		New-Item -ItemType Directory -Force -Path $folder | Out-Null 


		#Copy files, if exists
		if(Test-Path $fileToAdd) {
			#Write-Host -ForegroundColor Green "Folder: $folder"
			#Write-Host -ForegroundColor Green "File to add: $fileToAdd"
			Copy-Item $fileToAdd $folder
			$fileCount = $fileCount + 1
		}
		else {
			Write-Warning "Missing file: " # + $fileToAdd
			#Write-Warning $fileToAdd
			Write-Host -ForegroundColor Yellow $fileToAdd
		}
	}
}

# Copy environment specific files into stage
$envDir = "$STAGE_DIR"+"env\"+$env
Write-Host "Envdir: $envDir"
if(Test-Path $envDir) {
	Write-Host "Copying environment specific files into stage for: '$env'"
	Copy-Item -Recurse "$envDir\*" $STAGE_DIR 
}
else {
	Write-Host "No environment specific changes for: '$env'"
}

Write-Host  -ForegroundColor Cyan "Staging Completed, file count: $fileCount" 
$commitHash = git rev-parse HEAD 
Write-Host "Commit hash: $commitHash"  
#Return $commitHash
return 0
