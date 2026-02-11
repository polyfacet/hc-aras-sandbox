$versionFilePath = "$PSScriptRoot\..\version.txt"
$stageDateFilePath = "$PSScriptRoot\deploy\stage_from_date.txt"
echo "Create new baseline"
git checkout dev/main
git pull

Write-Host -ForegroundColor Green "Setting up clean myupdate.mf"
Copy-Item $PSScriptRoot\..\packages\MYAras\myupdate_base.mf -Destination $PSScriptRoot\..\packages\MYAras\myupdate.mf

echo "Set new version"
$previousVersion = Get-Content $versionFilePath -First 1
echo "Previous version: $previousVersion"
$minorVersion = $previousVersion.Remove(0, ($previousVersion.Length - 1))
$nextMinorVersion = [int]$minorVersion + 1
$nextVersion = $previousVersion.Substring(0, $previousVersion.Length -1) + $nextMinorVersion
Write-Host -ForegroundColor Green "New version: $nextVersion"
echo "Update version file"
$nextVersion | Out-File -FilePath $versionFilePath

echo "Set new baseline date"
$CURRENT_FROM_DATE = Get-Content $stageDateFilePath -First 1
echo "Current: $CURRENT_FROM_DATE"
$NEW_DATE = (Get-Date)
$NEW_DATE_FORMATED = $NEW_DATE.ToString("yyyy-MM-dd HH:mm:ss")
Write-Host -ForegroundColor Green "New baseline date: $NEW_DATE_FORMATED"
(Get-Content $stageDateFilePath) -replace $CURRENT_FROM_DATE, $NEW_DATE_FORMATED | Set-Content $stageDateFilePath

echo "Commiting changes"
git add ..\
git commit -m "deploy: New baseline for version $nextVersion"
Write-Host -ForegroundColor Green "Baseline has been updated."
Write-Host -ForegroundColor Yellow "Finish by reviewing the changes and then push."
