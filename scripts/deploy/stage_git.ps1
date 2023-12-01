$STAGE_DIR = "stage\"

$currentBranch = git branch --show-current
"Current Branch " + $currentBranch
Write-Host -ForegroundColor Cyan "Running local build on branch $currentBranch"

$FROM_DATE = Get-Content .\stage_from_date.txt -First 1
Write-Host -ForegroundColor Cyan "Staging with git from: " $FROM_DATE
git log --name-status --pretty="" --after=$FROM_DATE | Sort-Object -unique  > stage.log

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
		if (-NOT ($filePath.StartsWith("packages") -OR $filePath.StartsWith("webapp"))) {
			continue
		}
		#Write-Host -ForegroundColor Green $fileToAdd
		$fileToAdd
		
		$folder = Split-Path -parent $fileToAdd
		$folder = $STAGE_DIR + $folder
		
		$fileToAdd = "..\..\$fileToAdd"
		# Create folder, silent output
		New-Item -ItemType Directory -Force -Path $folder | Out-Null 

		#Copy files, if exists
		if(Test-Path $fileToAdd) {
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

if ($doZip -eq "--zip") {
	Write-Host "Zipping file to : .\.\stage\Deploy.zip"
	Compress-Archive -Path .\stage -DestinationPath .\stage\Deploy.zip
	explorer.exe .\stage
}

Write-Host  "Staging Completed, file count: $fileCount" 
$commitHash = git rev-parse HEAD 
Write-Host "Commit hash: $commitHash"  
#Return $commitHash
return 0
